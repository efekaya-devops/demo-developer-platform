import { createFrontendModule, PageBlueprint } from '@backstage/frontend-plugin-api';
import { ScaffolderPage, rootRouteRef } from '@backstage/plugin-scaffolder';
import { convertLegacyRouteRef } from '@backstage/core-compat-api';
import { makeStyles, Paper, Typography } from '@material-ui/core';
import ErrorOutlineIcon from '@material-ui/icons/ErrorOutline';

// hides manage/edit templates from the create page browse list (they're
// meant to be opened via a pre-filled link, not picked from the list).
// using the old ScaffolderPage here since the new one doesn't support
// filtering templates yet - page:scaffolder is turned off in app-config
// so this is the only /create route
const HIDDEN_TAGS = ['manage', 'edit'];

const useBannerStyles = makeStyles(theme => ({
  root: {
    display: 'flex',
    alignItems: 'flex-start',
    gap: theme.spacing(1.5),
    margin: theme.spacing(3, 3, 0, 3),
    padding: theme.spacing(2),
    borderLeft: `4px solid ${theme.palette.error.main}`,
    backgroundColor: theme.palette.type === 'dark' ? 'rgba(244,67,54,0.08)' : 'rgba(244,67,54,0.06)',
  },
  icon: {
    color: theme.palette.error.main,
    marginTop: 2,
    flexShrink: 0,
  },
  title: {
    color: theme.palette.error.main,
    fontWeight: 600,
  },
}));

// The hosted demo is read-only: the reverse proxy refuses anything that would
// write, so pressing Create returns 403. That's deliberate - a golden-path run
// creates a *public* repo in this GitHub org under a name the visitor chooses,
// and the ApplicationSet then deploys the result onto the single small box this
// demo runs on. Saying so up front turns a confusing failure into a documented
// boundary; the walkthrough recordings show the path actually completing.
const ReadOnlyNotice = () => {
  const classes = useBannerStyles();
  return (
    <Paper className={classes.root} elevation={0}>
      <ErrorOutlineIcon className={classes.icon} />
      <div>
        <Typography variant="subtitle2" className={classes.title}>
          Read-only demo — submitting will return 403, and that is expected
        </Typography>
        <Typography variant="body2" color="textSecondary">
          Browse the templates and step through the whole flow: every field,
          validation and the review screen behave exactly as they do in a real
          install. The final Create call is blocked at the proxy, because
          running it would create a public repository in this GitHub
          organisation and deploy a workload onto the single machine hosting
          this demo. Nothing you do here can change anything.
        </Typography>
      </div>
    </Paper>
  );
};

const scaffolderPage = PageBlueprint.make({
  name: 'create',
  params: {
    path: '/create',
    routeRef: convertLegacyRouteRef(rootRouteRef),
    loader: async () => (
      <>
        <ReadOnlyNotice />
        <ScaffolderPage
          templateFilter={entity =>
            !(entity.metadata.tags ?? []).some(t => HIDDEN_TAGS.includes(t))
          }
        />
      </>
    ),
  },
});

export const scaffolderPageModule = createFrontendModule({
  pluginId: 'app',
  extensions: [scaffolderPage],
});
