import {
  createFrontendModule,
  PageBlueprint,
} from '@backstage/frontend-plugin-api';
import { HomePage } from './HomePage';

const homePage = PageBlueprint.make({
  name: 'home',
  params: {
    path: '/',
    loader: async () => <HomePage />,
  },
});

export const homeModule = createFrontendModule({
  pluginId: 'app',
  extensions: [homePage],
});