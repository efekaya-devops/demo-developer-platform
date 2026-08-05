import { createApp } from '@backstage/frontend-defaults';
import catalogPlugin from '@backstage/plugin-catalog/alpha';
// shows the Kubernetes tab on entity pages, pulls from whatever cluster
// is configured under kubernetes: in app-config.yaml
import kubernetesPlugin from '@backstage/plugin-kubernetes/alpha';
import notificationsPlugin from '@backstage/plugin-notifications/alpha';
import scaffolderPlugin from '@backstage/plugin-scaffolder/alpha';
// without this there's no Docs tab at all, even though the template ships
// mkdocs.yml and the catalog annotation
import techdocsPlugin from '@backstage/plugin-techdocs/alpha';
// techdocs pages embed a search box, so without the search plugin registered
// the whole Docs tab dies on "no implementation for plugin.search.queryservice"
import searchPlugin from '@backstage/plugin-search/alpha';
import { navModule } from './modules/nav';
import { signInModule } from './modules/signIn';
import { scaffolderPageModule } from './modules/scaffolderPage';
import { homeModule } from './modules/home';

export default createApp({
  features: [
    catalogPlugin,
    kubernetesPlugin,
    notificationsPlugin,
    scaffolderPlugin,
    techdocsPlugin,
    searchPlugin,
    navModule,
    signInModule,
    scaffolderPageModule,
    homeModule,
  ],
});
