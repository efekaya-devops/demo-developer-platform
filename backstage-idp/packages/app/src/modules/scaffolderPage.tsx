import { createFrontendModule, PageBlueprint } from '@backstage/frontend-plugin-api';
import { ScaffolderPage, rootRouteRef } from '@backstage/plugin-scaffolder';
import { convertLegacyRouteRef } from '@backstage/core-compat-api';

// hides manage/edit templates from the create page browse list (they're
// meant to be opened via a pre-filled link, not picked from the list).
// using the old ScaffolderPage here since the new one doesn't support
// filtering templates yet - page:scaffolder is turned off in app-config
// so this is the only /create route
const HIDDEN_TAGS = ['manage', 'edit'];

const scaffolderPage = PageBlueprint.make({
  name: 'create',
  params: {
    path: '/create',
    routeRef: convertLegacyRouteRef(rootRouteRef),
    loader: async () => (
      <ScaffolderPage
        templateFilter={entity =>
          !(entity.metadata.tags ?? []).some(t => HIDDEN_TAGS.includes(t))
        }
      />
    ),
  },
});

export const scaffolderPageModule = createFrontendModule({
  pluginId: 'app',
  extensions: [scaffolderPage],
});
