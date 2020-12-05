package adminvm

import (
   "context"
   "log"
   "google.golang.org/api/compute/v1"
)

var projectID = os.Getenv("GCP_PROJECT")

type PubSubMessage struct {
    Data []byte `json:"data"`
}

func HelloPubSub(ctx context.Context, m PubSubMessage) error {
    name := string(m.Data) // Automatically decoded from base64.
    if name == "" {
        name = "World"
    }
    log.Printf("Hello, %s!", name)

    // ctx := context.Background()
    // c, err := google.DefaultClient(ctx, compute.CloudPlatformScope)
    c, err := google.DefaultClient(ctx.Background(), compute.CloudPlatformScope)
    if err != nil {
        log.Fatal(err)
    }
    computeService, err := compute.New(c)
    if err != nil {
            log.Fatal(err)
    }

    resp, err := computeService.Instances.Start(projectID, "us-central1-a", "foo").Context(ctx).Do()
    if err != nil {
            log.Fatal(err)
    }

   log.Printf("%#v\n", resp)

    return nil
}
