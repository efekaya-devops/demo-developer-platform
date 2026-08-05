import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { SignInPageBlueprint } from '@backstage/plugin-app-react';
import { SignInPage } from '@backstage/core-components';

// guest sign in for the demo, one click and you're in. swap for real oauth
// later, shouldn't need to touch anything else to do that
const guestSignInPage = SignInPageBlueprint.make({
  params: {
    loader: async () => (props: any) => (
      <SignInPage {...props} providers={['guest']} />
    ),
  },
});

export const signInModule = createFrontendModule({
  pluginId: 'app',
  extensions: [guestSignInPage],
});
