LinkedIn Data Dataproc
===

Google Dataproc environment for processing 2017 LinkedIn Profiles

We are tasked to create a private, queryable framework for a linkedin profile data trove. \
The Data is well formed json, compressed and sliced into 400 1GB chunks.

One way to accomplish this would be to put the data into a database such as postgres, and expose it to analysts. They could then use any tool to run analytics.

My theory is that 400GB (1.8TB uncompressed) is officially at the point where traditional database + pandas analysis will fail to scale to be performant, even on large compute instances. Creating a database and storing the data is a mostly unnecessary procedure considering analysts will be only be querying and downloading large portions to work with, not building applications with it.

It finally makes sense to try Apache Spark. Oh yes,

My solution is to:

1. Store the raw data in a Google Cloud Storage.

2. Utilize Apache Spark through GCP's Dataproc cluster as the computing engine

3. Deploy Datalab web interface to enhance usability of the framework for analysts



Goals of this project
---

[x] - Create easy to use GCP Dataproc init and teardown scripts.

[ ] - Migrate all data into Google Cloud Storage from Google Drive

- Install Rclone on VM via init script
- Configure Rclone with api key to gain access to Google Drive
- Clone data to VM disk
- Upload data to cloud bucket with gsutil

[ ] - Use pyspark to convert data to parquet file

- Figure out concatenation/file requirements for spark json import
- Create spark dataframe schema for json data reference
- Create dataframe of data
- Save to parquet file on google storage for simplified performant import

[ ] - Add additional cluster configurations for initialization script
- Different sized clusters - One node, three node, auto-scaling ...

[ ] - Learn how to submit jobs to dataproc

- Write a sample dataproc job
- Write an uploader script

[ ] - Run some speed tests
- Queries against Spark Dataframe vs Postgres


How To Use
---

1. You will first need a GCP account. Create one [here](https://console.cloud.google.com/).

    I will need your GCP email address to share the project with you before you install.

2. Download and install the Google Cloud SDK [here](https://cloud.google.com/sdk/)

3. Initialize gcloud, select linkedin-dataproc as your project

    ```shell
    gcloud init
    ```

4. Set gcloud configs

    ```bash
    gcloud config set compute/region us-east1
    gcloud config set compute/zone us-east1-b
    ```

5. Source dataproc/env.sh, then run dataproc-utils init, spin up cluster, ssh tunnel and open dataproc chrome interface

    ```bash
    source dataproc/env.sh
    dataproc-utils init
    ```

6. To fully terminate session, Press Ctrl + C and quit chrome dataproc portal

7. Remember to deprovision the cluster when you are done! Run cleanup.sh to deprovision cluster and remove aliases set by env.sh.

    ```bash
    dataproc-utils cleanup
    ```

Configuration
---

Configuration is limited to the project variables in env.sh
More to come