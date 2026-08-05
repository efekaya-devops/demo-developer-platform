import {
  Content,
  Header,
  Page,
} from '@backstage/core-components';

import {
  Grid,
  Card,
  CardContent,
  Typography,
  Button,
} from '@material-ui/core';

import { Link } from 'react-router-dom';

export function HomePage() {
  return (
    <Page themeId="home">
      <Header
        title="Internal Developer Platform"
        subtitle="Welcome to the developer portal"
      />

      <Content>

        <Grid container spacing={3}>

          <Grid item xs={12}>
            <Typography variant="h5">
              Quick Actions
            </Typography>
          </Grid>

          <Grid item md={4}>
            <Card>
              <CardContent>
                <Typography variant="h6">
                  Create Service
                </Typography>

                <Button
                  component={Link}
                  to="/create"
                  variant="contained"
                  color="primary"
                >
                  Open
                </Button>
              </CardContent>
            </Card>
          </Grid>

          <Grid item md={4}>
            <Card>
              <CardContent>
                <Typography variant="h6">
                  Software Catalog
                </Typography>

                <Button
                  component={Link}
                  to="/catalog"
                  variant="contained"
                >
                  Browse
                </Button>
              </CardContent>
            </Card>
          </Grid>

          <Grid item md={4}>
            <Card>
              <CardContent>
                <Typography variant="h6">
                  Kubernetes
                </Typography>

                <Button
                  component={Link}
                  to="/catalog?filters[kind]=component"
                >
                  Explore
                </Button>
              </CardContent>
            </Card>
          </Grid>

        </Grid>

      </Content>
    </Page>
  );
}