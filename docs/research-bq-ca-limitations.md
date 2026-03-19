Conversational Analytics API has the following known limitations on the number of data sources, style of visualizations, and size of datasets.

## Data source limitations

When you connect to a Looker data source, note the following:

- You can query any included Explore in a conversation.
- An agent can only query one Explore at a time. It is not possible to perform queries across multiple Explores simultaneously.
- An agent can query multiple Explores in the same conversation.
An agent can query multiple Explores in a conversation that includes questions with multiple parts, or in conversations that include follow-up questions.

For example: A user connects two Explores, one called

`cat-explore`

and one called`dog-explore`

. The user inputs the question "What's greater: the count of cats or the count of dogs?" This would create two queries: one to count the number of cats in`cat-explore`

and one to count the number of dogs in`dog-explore`

. The agent compares the number from both queries after completing both queries.The

`QueryData`

method does not support BigQuery or Looker data sources.The

`Chat`

and`DataAgent`

methods don't support database data sources such as AlloyDB for PostgreSQL, Spanner, Cloud SQL, and Cloud SQL for PostgreSQL.

## Visualization limitations

- These visualization types are fully supported: Line chart, area chart, bar (horizontal, vertical, stacked) chart, scatterplots, pie chart
- These visualization types are partially supported and may exhibit unexpected behavior: Maps, heatmaps, charts with tooltips

## Data processing limitations

- For Looker data sources, the Conversational Analytics API can return a maximum of
**5,000 rows**per query. - For BigQuery data sources, the Conversational Analytics API limits data queries to 500 GB of bytes processed.
- The Conversational Analytics API's Python-based reasoning and content retrieval capabilities can accommodate time complexities of up to
`O(100k)`

rows. - Querying large amounts of data can cause reduced reasoning accuracy in data agents.
- The Conversational Analytics API has a maximum token output length of
**8,192 tokens**. Querying large amounts of data can return a`MAX_TOKENS`

error. - The data returned within the
`DataResult`

field of a system message is subject to a size limit. Data results are truncated to a maximum of 3,000,000 bytes. This truncation process keeps as many full rows as possible within this size constraint.

## Query limitations

- BigQuery's flexible column names feature is not supported.
- Structs in BigQuery are supported but may sometimes fail.
- For Looker data sources, the API cannot set the value of a filter-only field that is defined by using the LookML
`parameter`

parameter. - Using the Conversational Analytics API to connect to a private IP Looker (Google Cloud core) instance using Looker Studio Pro when that Looker (Google Cloud core) instance is inside a VPC Service Controls perimeter is not a supported configuration and does not meet VPC Service Controls compliance requirements.
- For connections to
[Looker (Google Cloud core) instances with private IP configurations](https://docs.cloud.google.com/looker/docs/looker-core-networking-options#private_ip_connections), Conversational Analytics API does not support Looker (Google Cloud core) instances that are configured to use[CMEK](https://docs.cloud.google.com/looker/docs/looker-core-cmek)or VPC Service Controls. - Conversational Analytics API doesn't work well with Looker Studio data sources that have
[field editing in reports](https://docs.cloud.google.com/looker/docs/studio/edit-fields-in-your-reports)disabled in because this setting prevents Conversational Analytics from creating calculated fields. When a failure occurs during query validation or execution, the Conversation Analytics API may automatically retry the operation by generating a corrected query. This kind of retry will be attempted a maximum of three times per request.

If a query fails because of permission or authentication issues, the Conversational Analytics API won't retry the query. Retries are non-deterministic; if the error message suggests that a query is unrecoverable, then the API won't try the query again, even if it is still below the limit of three errors per request.

**Conversational Analytics API has a maximum of 10 Queries Per Second (QPS). This results in a maximum of 600 Queries Per Minute (QPM) per project, and 600 QPM per user per project.**

## Question types limitations

Conversational Analytics API supports questions that can be answered by a single visualization, for example:

- Metric trends over time
- Breakdown or distribution of a metric by dimension
- Unique values for one or more dimensions
- Single metric values
- The top dimension values by metric

Conversational Analytics API doesn't yet support questions that can only be answered with the following types of complicated visualizations:

- Prediction and forecasting
- Advanced statistical analysis, including correlation and anomaly detection