export interface Config {
  app: {
    /**
     * Shows the read-only notice on the Create pages. Set in
     * app-config.production.yaml only, so a local `yarn start` - where the
     * scaffolder actually works - stays quiet.
     *
     * The visibility marker is what makes this reach the browser at all:
     * config keys with no schema behind them are treated as backend-only and
     * stripped out of what the frontend receives, so the notice would silently
     * never render on the deployment it exists for.
     *
     * @visibility frontend
     */
    readOnlyDemo?: boolean;
  };
}
