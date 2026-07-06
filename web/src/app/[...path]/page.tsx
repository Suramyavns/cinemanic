'use client'
import { usePathname, useSearchParams, useRouter } from "next/navigation";
import { useEffect, useRef, useCallback, Suspense, useState } from "react";
import { ChevronLeft, SkipForward } from 'lucide-react';
import { fetchShowDetails, fetchMovieDetails } from "@/services/tmdb";
import { auth } from "@/lib/firebase";

const PROGRESS_FLUSH_INTERVAL  = 10000;

function PlayerContent() {
  const path = usePathname();
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get('token');
  const startAtParam = searchParams.get('startAt');
  const isAnime = searchParams.get('isAnime') === 'true';
  const startAt = startAtParam ? parseFloat(startAtParam) : null;
  const [details, setDetails] = useState<any>(null);

  const pendingMediaDataRef = useRef<any>(null);
  const lastSavedJsonRef = useRef<string | null>(null);

  // The token in the URL is a Firebase ID token grabbed once when the player
  // was opened. It expires after an hour and is never refreshed, so long
  // sessions silently 401 on every save after that. Always prefer a fresh
  // token from the live auth instance; the URL token is only a fallback for
  // the brief window before Firebase auth rehydrates (AuthGuard skips the
  // auth check on player routes, so that window isn't guaranteed to be closed
  // by the time this component mounts).
  const getAuthToken = useCallback(async () => {
    if (auth.currentUser) {
      try {
        return await auth.currentUser.getIdToken();
      } catch (error) {
        console.error('Failed to refresh auth token:', error);
      }
    }
    return token;
  }, [token]);

  const saveProgress = useCallback(async (mediaData: any, opts: { keepalive?: boolean } = {}) => {
    if (!mediaData) return;
    const json = JSON.stringify(mediaData);
    if (json === lastSavedJsonRef.current) return;

    const authToken = await getAuthToken();
    if (!authToken) return;

    try {
      const res = await fetch('/api/watch/progress', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authToken}`
        },
        body: json,
        keepalive: opts.keepalive ?? false,
      });

      if (!res.ok) {
        console.error('Failed to sync watch progress:', res.status, await res.text().catch(() => ''));
        return;
      }
      lastSavedJsonRef.current = json;
    } catch (error) {
      console.error('Failed to sync watch progress:', error);
    }
  }, [getAuthToken]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const playerUrl = process.env.NEXT_PUBLIC_PLAYER_URL || 'https://vidlink.pro';
      let playerOrigin = playerUrl;
      try { playerOrigin = new URL(playerUrl).origin; } catch { /* keep raw value */ }
      if (event.origin !== playerOrigin && !event.origin.includes('vidsrcme.ru')) return;

      if (event.data?.type === 'MEDIA_DATA') {
        const mediaData = event.data.data;

        if ((window as any).WatchHistoryChannel) {
             (window as any).WatchHistoryChannel.postMessage(JSON.stringify(mediaData));
        }

        pendingMediaDataRef.current = mediaData;
      }
    };

    // Trailing-edge flush: guarantees the latest position is actually saved
    // at a fixed cadence, instead of only-ever dropping updates that arrive
    // less than 10s apart with no follow-up save.
    const interval = setInterval(() => {
      if (pendingMediaDataRef.current) saveProgress(pendingMediaDataRef.current);
    }, PROGRESS_FLUSH_INTERVAL);

    // A plain fetch can get cancelled when the tab is closed/backgrounded;
    // keepalive lets it complete after the page starts unloading.
    const flushOnHide = () => {
      if (pendingMediaDataRef.current) saveProgress(pendingMediaDataRef.current, { keepalive: true });
    };
    const handleVisibility = () => {
      if (document.visibilityState === 'hidden') flushOnHide();
    };

    window.addEventListener('message', handleMessage);
    window.addEventListener('pagehide', flushOnHide);
    document.addEventListener('visibilitychange', handleVisibility);

    return () => {
      window.removeEventListener('message', handleMessage);
      window.removeEventListener('pagehide', flushOnHide);
      document.removeEventListener('visibilitychange', handleVisibility);
      clearInterval(interval);
    };
  }, [saveProgress]);

  const parts = path.split('/').filter(Boolean);
  const mediaType = parts[0];
  const id = parts[1];
  const season = parts[2] ? parseInt(parts[2]) : 1;
  const episode = parts[3] ? parseInt(parts[3]) : 1;

  useEffect(() => {
    const loadDetails = async () => {
      const authToken = await getAuthToken();
      if (!authToken) return;
      try {
        const data = mediaType === 'movie'
          ? await fetchMovieDetails(id, authToken)
          : await fetchShowDetails(id, authToken);
        setDetails(data);
      } catch (error) {
        console.error('Failed to load details for navigation:', error);
      }
    };
    loadDetails();
  }, [id, mediaType, getAuthToken]);

  // Record initial watch history entry
  useEffect(() => {
    if (!details) return;

    const recordHistory = async () => {
      const authToken = await getAuthToken();
      if (!authToken) return;

      try {
        const mediaData = {
          id: details.id,
          type: mediaType,
          title: details.title || details.name,
          poster_path: details.poster_path,
          backdrop_path: details.backdrop_path,
          last_updated: Date.now(),
          // preserve current progress if any
          progress: startAt ? { watched: startAt, duration: 0 } : { watched: 0, duration: 0 },
          last_season_watched: mediaType === 'tv' ? season.toString() : undefined,
          last_episode_watched: mediaType === 'tv' ? episode.toString() : undefined,
        };

        const res = await fetch('/api/watch/progress', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authToken}`
          },
          body: JSON.stringify({ mediaData: { [details.id]: mediaData } }),
        });

        if (!res.ok) {
          console.error('Failed to record initial watch history:', res.status, await res.text().catch(() => ''));
        }
      } catch (error) {
        console.error('Failed to record initial watch history:', error);
      }
    };

    recordHistory();
  }, [getAuthToken, details?.id, mediaType, season, episode]); // Run when content changes

  const handleNextEpisode = () => {
    // Flush whatever position we have for the episode being left — the
    // player iframe gets torn down immediately on navigation, so this is the
    // last chance to save it.
    if (pendingMediaDataRef.current) saveProgress(pendingMediaDataRef.current);

    if (!details || mediaType !== 'tv') {
      // Fallback simple increment if details haven't loaded
      const nextEpisode = episode + 1;
      const nextPath = `/${mediaType}/${id}/${season}/${nextEpisode}`;
      const query = `?token=${token}&isAnime=${isAnime}`;
      router.replace(`${nextPath}${query}`);
      return;
    }

    const currentSeason = details.seasons?.find((s: any) => s.season_number === season);
    const maxEpisodesInSeason = currentSeason?.episode_count || 100; // Fallback
    const totalSeasons = details.number_of_seasons || 1;

    let nextEpisode = episode + 1;
    let nextSeason = season;

    if (nextEpisode > maxEpisodesInSeason) {
      if (season < totalSeasons) {
        nextSeason = season + 1;
        nextEpisode = 1;
        // Check if next season exists in the seasons array (important for shows with specials/season 0)
        const nextSeasonExists = details.seasons?.some((s: any) => s.season_number === nextSeason);
        if (!nextSeasonExists) {
            // If next season gap exists, maybe just stop or try skipping? 
            // For simplicity, we'll just try to navigate
        }
      } else {
        // Last episode of last season
        alert("You've reached the end of the show!");
        return;
      }
    }

    const nextPath = `/${mediaType}/${id}/${nextSeason}/${nextEpisode}`;
    const query = `?token=${token}&isAnime=${isAnime}`;
    router.replace(`${nextPath}${query}`);
  };

  const playerUrl = process.env.NEXT_PUBLIC_PLAYER_URL || 'https://vidlink.pro';
  const animePlayerUrl = 'https://vidsrcme.ru';
  
  const iframeUrl = isAnime 
    ? `https://vidsrcme.ru/embed/${mediaType === 'movie' ? 'movie' : 'tv'}?tmdb=${id}${mediaType === 'tv' ? `&season=${season}&episode=${episode}` : ''}&autoplay=1&autonext=1`
    : `${playerUrl}/${mediaType === 'movie' ? 'movie' : 'tv'}/${id}${mediaType === 'tv' ? `/${season}/${episode}` : ''}?player=jw&iconColor=ffffff&primaryColor=ffffff&secondaryColor=ffffff&autoplay=true`;

  return (
    <div className="relative w-full h-screen bg-black overflow-hidden group">
      <iframe
        src={iframeUrl}
        width="100%"
        height="100%"
        allowFullScreen
        style={{ border: "none" }}
      />

      {/* Custom Player Overlay */}
      <div className="absolute top-0 left-0 w-full p-6 flex items-center justify-between opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none z-50">
        <button 
          onClick={() => router.back()}
          className="pointer-events-auto flex items-center gap-2 bg-black/50 hover:bg-black/80 backdrop-blur-md text-white px-4 py-2 rounded-full border border-white/10 transition-all font-bold group/btn active:scale-95"
        >
          <ChevronLeft className="w-5 h-5 group-hover/btn:-translate-x-1 transition-transform" />
          <span>Back</span>
        </button>

        {/* Center Label */}
        <div className="absolute left-1/2 -translate-x-1/2 pointer-events-none">
          {details?.title || details?.name || 'Loading...'}
          {mediaType === 'tv' && (
            <span className="text-white/40 text-sm font-bold ml-2 hidden md:inline">
              S{season} : E{episode}
            </span>
          )}
        </div>

        {mediaType === 'tv' && (
          <button
            onClick={handleNextEpisode}
            className="pointer-events-auto flex items-center gap-2 bg-white text-black px-6 py-2 rounded-full transition-all font-bold group/btn active:scale-95 hover:bg-blue-500 hover:text-white"
          >
            <span>Next Episode</span>
            <SkipForward className="w-5 h-5 fill-current" />
          </button>
        )}
      </div>

    </div>
  );
}

export default function PlayerPage() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <PlayerContent />
    </Suspense>
  );
}