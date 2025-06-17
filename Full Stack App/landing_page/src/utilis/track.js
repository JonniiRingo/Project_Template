// src/utils/track.js
export async function track(project) {
  try {
    await fetch('/api/track', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ project })
    });
  } catch {
    // analytics failure should never break the UI
  }
}