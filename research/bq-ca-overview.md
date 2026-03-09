# Conversational analytics overview

Conversational analytics in BigQuery lets you chat with agents about your data using natural language. To get answers about your data, you can do the following:

- Create
[data agents](https://docs.cloud.google.com#data-agents)that automatically define data context and query processing instructions for a set of knowledge sources, such as tables, views, or user-defined functions (UDFs) that you select. - If needed, you can create context and instructions for an agent in the form
of custom table and field metadata, instructions to the agent for interpreting
and querying the data, or by creating verified queries
(previously known as
*golden queries*) to configure the data agent to effectively answer questions for specific use cases.

Before customizing an agent, it's recommended that you first work with the context and instructions that the agent creates.

Some examples of context and instructions that you provide to the agent are the following:

**Context.**A data agent for sales analysis can be configured to understand that "top performers" refers to sales representatives with the highest revenue, rather than just the most closed deals.**Instructions.**You can instruct a data agent to always filter data to the most recent quarter when asked about "trends," or to group results by "product category" by default.

After creating data agents, you can then have
[conversations](https://docs.cloud.google.com#conversations) with them to ask questions about
BigQuery data by using natural language. You can also create
[direct conversations](https://docs.cloud.google.com/bigquery/docs/create-conversations) with one or more
data sources to answer basic, one-off questions.

Conversational analytics is powered by [Gemini for Google
Cloud](https://docs.cloud.google.com/gemini/docs/overview) and supports some BigQuery ML functions. For
more information, see [BigQuery ML support](https://docs.cloud.google.com#bigquery-ml-support).

Learn [how and when Gemini
for Google Cloud uses your data](https://docs.cloud.google.com/gemini/docs/discover/data-governance).

## Data agents

Data agents consist of one or more knowledge sources, and a set of instructions specific to a use case for processing that data. When you create a data agent, you can configure it using the following options:

- Use
*knowledge sources*such as tables, views, and UDFs with a data agent. - Provide custom table and field metadata to describe the data in the most appropriate way for the given use case.
- Provide instructions for interpreting and querying the data, such as
defining the following:
- Synonyms and business terms for field names
- Most important fields and defaults for filtering and grouping

- Create
*verified queries*that the data agent can use to shape an agent's response structure and to learn the business logic that your organization uses. Verified queries were previously known as*golden queries*. Verified queries can use[supported BigQuery ML functions](https://docs.cloud.google.com#bigquery-ml-support). - Create BigQuery custom glossary terms for each agent or
import business glossary terms from Dataplex Universal Catalog. These terms
help an agent interpret user prompts. For advice on when to use each type,
see
[Create or review glossary terms](https://docs.cloud.google.com/bigquery/docs/create-data-agents#create-review-glossary-terms).

### Manage data agents

You can create, manage, and work with the following types of data agents in the
**Agent Catalog** tab in the Google Cloud console:

- A predefined sample agent for each Google Cloud project.
- A list of your drafted, created, and published agents.
- A list of agents that other people create and share with you.

For more information, see [Create data
agents](https://docs.cloud.google.com/bigquery/docs/create-data-agents).

Other services in the project that support data agents, such as the
[Conversational Analytics API](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/overview)
and
[Looker Studio](https://docs.cloud.google.com/looker/docs/studio/conversational-analytics-looker-studio)
Pro, can access data agents that you create in BigQuery. You can
also access an agent created in the Google Cloud console by calling it using
the [Conversational Analytics
API](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/overview).

## Conversations

Conversations are persisted chats with a data agent or data source. You can ask data agents multi-part questions that use common terms like "sales" or "most popular," without having to specify table field names or define conditions to filter the data. You can also ask questions about data located in objects such as PDFs.

The chat response returned to you provides the following features:

- The answer to your question as text, code, or images (multimodal). The answer can include supported BigQuery ML functions.
- Generated charts where appropriate.
- The agent's reasoning behind the results.
- Metadata about the conversation, such as the agent and data sources used.

When you create a direct conversation with a data source, the
[Conversational Analytics API](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/overview)
interprets your question without the context and processing instructions that a
data agent offers. Because of this, direct conversation results can be less
accurate. Use data agents for cases that require greater accuracy.

You can create and manage conversations in BigQuery using the
Google Cloud console. For more information, see [Analyze data with
conversations](https://docs.cloud.google.com/bigquery/docs/create-conversations).

## BigQuery ML support

Conversational analytics supports the following BigQuery ML functions in response to chats with data agents and data sources, and in verified SQL queries that you create.

`AI.FORECAST`

`AI.DETECT_ANOMALIES`

, including`AI.GENERATE`

,`AI.GENERATE_BOOL`

, and`AI.GENERATE_INT`

`AI.GENERATE_DOUBLE`


To use the supported `AI.GENERATE`

functions, you must have [the required
permissions](https://docs.cloud.google.com/bigquery/docs/permissions-for-ai-functions#run_generative_ai_queries_with_end-user_credentials)
to run generative AI queries.

### BigQuery ML use cases

To activate supported BigQuery ML functions, use them in the following ways:

- When you create an agent and add a verified query—for example, if you are a data scientist who prepares a recurring report—you can use supported BigQuery ML functions in a verified query to describe defaults and automate the report.
- When you ask high-level questions about data to an agent, in a conversation, or in a verified query using keywords, the agent generates the BigQuery ML SQL in response to your questions.

The following table shows examples of one-shot prompts that activate the use of BigQuery ML:

| Use case | Sample usage |
|
|---|

`bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`

`bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`

`bigquery-public-data.bbc_news.fulltext`

## Security

You can manage access to conversational analytics in BigQuery
using [Conversational Analytics API IAM roles and
permissions](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/access-control). For
information about the roles needed for specific operations, see the [data agent
required roles](https://docs.cloud.google.com/bigquery/docs/create-data-agents#required_roles) and the
[conversation required
roles](https://docs.cloud.google.com/bigquery/docs/create-conversations#required_roles).

## Locations

Conversational analytics operates globally; you can't choose which region to use.

## Pricing

You are charged at [BigQuery compute
pricing](https://docs.cloud.google.com/bigquery/pricing#analysis_pricing_models) for queries that run when
you create data agents and have conversations with data agents or data
sources. There is no additional charge for creating and using data agents and
conversations during the Preview period.

### Best practices

When using conversational analytics, queries are automatically run to answer your questions. You might incur unforeseen charges in the following cases:

- If your tables are large
- If the queries use data joins
- If the queries make a lot of calls to AI functions

To prevent this issue, consider size when selecting knowledge sources, and when having conversations, consider using joins.

## Dynamic shared quota

Dynamic Shared Quota (DSQ) in Vertex AI manages capacity for the Gemini model. Unlike conventional quotas, DSQ lets you access a large shared pool of resources without a fixed per-project limit for model throughput.

Performance, such as latency, can vary depending on the overall
system load. During times of high demand across the shared pool, you might
occasionally experience temporary `429 Resource Exhausted`

errors. These errors
indicate that the shared pool capacity is momentarily constrained, but not that
you have reached a specific quota limit on your project. To check on the
capacity, retry the request after a short delay.

## What's next

- Learn more about the
[Conversational Analytics API](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/overview). [Create data agents](https://docs.cloud.google.com/bigquery/docs/create-data-agents).[Analyze data with conversations](https://docs.cloud.google.com/bigquery/docs/create-conversations).