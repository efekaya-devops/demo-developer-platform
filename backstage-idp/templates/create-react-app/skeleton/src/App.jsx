import { useState } from 'react';

export default function App() {
  const [count, setCount] = useState(0);

  return (
    <main>
      <h1>${{ values.name }}</h1>
      <p className="lede">${{ values.description }}</p>

      <button onClick={() => setCount(c => c + 1)}>clicked {count} times</button>

      <section>
        <h2>What you got</h2>
        <ul>
          <li>Built by Vite, served by nginx as static files</li>
          <li>Deployed by ArgoCD, which found this repo on its own</li>
          <li>Scraped by Prometheus — yes, a frontend with real metrics</li>
          <li>A Grafana dashboard nobody had to create</li>
        </ul>
        <p className="hint">
          Replace this component with your app. Everything around it already works.
        </p>
      </section>
    </main>
  );
}
