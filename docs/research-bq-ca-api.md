Developers can use the Conversational Analytics API, which is accessed through `geminidataanalytics.googleapis.com`

, to build an artificial intelligence (AI)-powered chat interface, or *data agent*. The API uses natural language to answer questions about structured data in BigQuery, Looker, and Looker Studio, and also supports querying data from AlloyDB, GoogleSQL for Spanner, Cloud SQL, and Cloud SQL for PostgreSQL through the new `QueryData`

method. With the Conversational Analytics API, you provide your data agent with business information and data (*context*), as well as access to tools such as SQL, Python, and visualization libraries. These agent responses are presented to the user and can be logged by the client application, creating a seamless and auditable data chat experience.

Learn [how and when Gemini
for Google Cloud uses your data](https://docs.cloud.google.com/gemini/docs/discover/data-governance).

## Get started with the Conversational Analytics API

To start using the Conversational Analytics API, you can first review the [architecture and key concepts](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/key-concepts) documentation to understand how agents process requests, the workflows for agent creators and users, conversation modes, and Identity and Access Management (IAM) roles. You can also watch this video introduction to the [Conversational Analytics API](https://www.youtube.com/watch?v=c3WSg0Bpmt4) for an overview of the API and its key capabilities.

To start building data agents, you can choose between a guided experience with [quickstarts](https://docs.cloud.google.com#quickstarts), [codelabs](https://docs.cloud.google.com#codelabs), [notebooks](https://docs.cloud.google.com#notebooks), the [Agent Development Kit (ADK) and MCP Toolbox](https://docs.cloud.google.com#agent-development-kit-tools), or a self-driven approach by following the steps in [Setup and prerequisites](https://docs.cloud.google.com#setup).

### Quickstarts

Use the [Streamlit Quickstart app](https://github.com/looker-open-source/ca-api-quickstarts) to integrate with the Conversational Analytics API in a local test environment.

Review the [Conversational Analytics demos and tools](https://github.com/looker-open-source/ca-demos-and-tools) that showcase the Conversational Analytics API capabilities and provide practical integration patterns.

### Codelabs

Follow a step-by-step tutorial to learn how to use the Python SDK with BigQuery data with the [Conversational Analytics API Codelab](https://codelabs.developers.google.com/ca-api-bigquery).

### Notebooks

Use the following Conversational Analytics API Colaboratory notebooks for guided experiences to help you get started with the Conversational Analytics API:

[HTTP Colaboratory notebook](https://colab.research.google.com/github/GoogleCloudPlatform/generative-ai/blob/main/agents/gemini_data_analytics/intro_gemini_data_analytics_http.ipynb): Provides an interactive, step-by-step guide to setting up your environment, building a data agent, and making API calls by using HTTP requests.[Python SDK Colaboratory notebook](https://colab.research.google.com/github/GoogleCloudPlatform/generative-ai/blob/main/agents/gemini_data_analytics/intro_gemini_data_analytics_sdk.ipynb): Provides an interactive, step-by-step guide to setting up your environment, building a data agent, and making API calls by using the Python SDK.

### Agent Development Kit (ADK) and MCP Toolbox

Learn how to use the `ask_data_insights`

function in the [Agent Development Kit (ADK)](https://google.github.io/adk-docs/tools/built-in-tools/#bigquery) to answer questions about your data in natural language.

The [MCP Toolbox for Databases](https://googleapis.github.io/genai-toolbox/getting-started/introduction/) provides the following tools for querying your data sources in natural language by using the Conversational Analytics API:

[BigQuery Conversational Analytics Tool](https://googleapis.github.io/genai-toolbox/resources/tools/bigquery/bigquery-conversational-analytics)(`bigquery-conversational-analytics`

): Query BigQuery data.[Looker Conversational Analytics Tool](https://googleapis.github.io/genai-toolbox/resources/tools/looker/looker-conversational-analytics)(`looker-conversational-analytics`

): Query Looker data.

### Client libraries

Installation instructions and reference documentation are available for the following Conversational Analytics API client libraries:

### Setup and prerequisites

Before you use the API or the examples, complete the following steps:

[Enable the Conversational Analytics API](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/enable-the-api): Describes prerequisites to enable the Conversational Analytics API.[Conversational Analytics API access control with IAM](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/access-control): Describes how to use Identity and Access Management to share and manage access to data agents.[Authenticate and connect to a data source with the Conversational Analytics API](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/authentication): Provides instructions for authenticating to the API and configuring connections to your BigQuery, Looker, Looker Studio, and Cloud Databases data (AlloyDB, GoogleSQL for Spanner, Cloud SQL, and Cloud SQL for PostgreSQL).

### Build and interact with a data agent

After completing the previous steps, use the Conversational Analytics API to build and interact with a data agent by following these steps:

[Build a data agent using HTTP](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/build-agent-http): Provides a complete example of building and interacting with a data agent by using direct HTTP requests with Python.[Build a data agent using the Python SDK](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/build-agent-sdk): Provides a complete example of building and interacting with a data agent by using the Python SDK.[Guide agent behavior with authored context](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/data-agent-system-instructions): Learn how to provide authored context to guide agent behavior and improve response accuracy. You can also view examples of authored context with[BigQuery data sources](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/data-agent-authored-context-bq)and with[Looker data sources](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/data-agent-authored-context-looker).[Render a Conversational Analytics API agent response as a visualization](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/render-visualization): Provides an example of processing chart specifications from API responses and rendering them as visualizations by using the Python SDK and the Vega-Altair library.

## Best practices

Review the following guides to learn about best practices for using the Conversational Analytics API:

[Manage BigQuery costs for your agents](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/manage-costs): Learn how to monitor and manage BigQuery costs for your Conversational Analytics API agents by setting project-level, user-level, and query-level spending limits.[Ask effective questions](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/ask-effective-questions): Learn how to craft effective questions for your agents to get the most out of the Conversational Analytics API.[Troubleshoot Conversational Analytics API errors](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/troubleshoot-ca-errors): Troubleshoot common Conversation Analytics API errors.[Known limitations](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/known-limitations): Provides detailed information about known limitations of the Conversational Analytics API, including limitations of queries, data, visualizations, and questions.[Render agent responses for Looker data sources](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/render-looker-data): Learn best practices for rendering Conversational Analytics API responses in a user interface when you're using Looker data sources.

## Key API operations

The API provides the following core endpoints for managing data agents and conversations:

| Operation | HTTP method | Endpoint | Description |
|---|---|---|---|
| Create an agent | `POST` |
`/v1beta/projects/*/locations/*/dataAgents` |
Creates a new data agent. |
| Create an agent synchronously | `POST` |
`/v1beta/projects/*/locations/*/dataAgents:createSync` |
Creates a new data agent synchronously. |
| Get an agent | `GET` |
`/v1beta/projects/*/locations/*/dataAgents/*` |
Retrieves the details of a specific data agent. |
| Get Identity and Access Management policy | `POST` |
`/v1beta/projects/*/locations/*/dataAgents/*:getIamPolicy` |
Gets the Identity and Access Management permissions that are assigned to each user for a specific data agent. Users with a
`setIAMpolicy` endpoint to share a data agent with other users. |

`POST`

`/v1beta/projects/*/locations/*/dataAgents/*:setIamPolicy`

[Data Agent Owner role](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/access-control#data-agent-owner)should call this endpoint to share a data agent with other users, which effectively updates those users' Identity and Access Management permissions.`PATCH`

`/v1beta/projects/*/locations/*/dataAgents/*`

`PATCH`

`/v1beta/projects/*/locations/*/dataAgents/*:updateSync`

`GET`

`/v1beta/projects/*/locations/*/dataAgents`

`GET`

`/v1beta/projects/*/locations/*/dataAgents:listaccessible`

`get`

permission on the agent. You can use the `creator_filter`

field to manage which agents this method returns:
`NONE`

(default): Returns all data agents that are accessible to the user, regardless of who created the agents.`CREATOR_ONLY`

: Returns only the data agents that are accessible to the user and that were created by that user.`NOT_CREATOR_ONLY`

: Returns only the data agents that are accessible to the user and that were created by others.

`DELETE`

`/v1beta/projects/*/locations/*/dataAgents/*`

`DELETE`

`/v1beta/projects/*/locations/*/dataAgents/*:deleteSync`

`POST`

`/v1beta/projects/*/locations/*/conversations`

`POST`

`/v1beta/projects/*/locations/*:chat`

`POST`

`/v1beta/projects/*/locations/*:chat`

`POST`

`/v1beta/projects/*/locations/*:chat`

`GET`

`/v1beta/projects/*/locations/*/conversations/*`

`GET`

`/v1beta/projects/*/locations/*/conversations`

`GET`

`/v1beta/projects/*/locations/*/conversations/*/messages`

`DELETE`

`/v1beta/projects/*/locations/*/conversations/*`

[Topic Admin](https://docs.cloud.google.com/iam/docs/roles-permissions/cloudaicompanion#cloudaicompanion.topicAdmin)Identity and Access Management role or at least the[Identity and Access Management permission is required to call this endpoint.](https://docs.cloud.google.com/iam/docs/roles-permissions/cloudaicompanion#cloudaicompanion.topics.delete)`cloudaicompanion.topics.delete`

`POST`

`/v1beta/projects/*/locations/*/conversations:queryData`

## Send feedback

Use the following links to file a bug or request a feature.

## Additional resources

The [Conversational Analytics API REST reference](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/reference/rest) provides detailed descriptions of methods, endpoints, and type definitions for request and response structures.