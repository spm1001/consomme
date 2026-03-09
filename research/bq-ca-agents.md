# Create data agents

This document describes how to create, edit, manage, and delete data agents in BigQuery.

In BigQuery, you can have
[conversations](https://docs.cloud.google.com/bigquery/docs/ca/create-conversations)
with data agents to ask questions about BigQuery data using
natural language. Data agents contain table metadata and use-case-specific query
processing instructions that define the best way to answer user questions about
a set of knowledge sources, such as tables, views, or user-defined functions
(UDFs) that you select.

## Before you begin

-
[Verify that billing is enabled for your Google Cloud project](https://docs.cloud.google.com/billing/docs/how-to/verify-billing-enabled#confirm_billing_is_enabled_on_a_project). -
Enable the BigQuery, Gemini Data Analytics, and Gemini for Google Cloud APIs.

**Roles required to enable APIs**To enable APIs, you need the Service Usage Admin IAM role (

`roles/serviceusage.serviceUsageAdmin`

), which contains the`serviceusage.services.enable`

permission.[Learn how to grant roles](https://docs.cloud.google.com/iam/docs/granting-changing-revoking-access).

### Required roles

To work with data agents, you must have one of the following [Conversational
Analytics API Identity and Access Management
roles](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/access-control):

- Create, edit, share, and delete all data agents in the project: Gemini Data
Analytics Data Agent Owner (
`roles/geminidataanalytics.dataAgentOwner`

) on the project. - Create, edit, share, and delete your own data agents in the project: Gemini
Data Analytics Data Agent Creator
(
`roles/geminidataanalytics.dataAgentCreator`

) on the project. This role automatically grants you the Gemini Data Analytics Data Agent Owner role on the data agents that you create. - View and edit all data agents in the project: Gemini Data Analytics Data
Agent Editor (
`roles/geminidataanalytics.dataAgentEditor`

) at the project level. - View all data agents in the project: Gemini Data Analytics Data Agent Viewer
(
`roles/geminidataanalytics.dataAgentViewer`

).

Additionally, you must have the following roles to create or edit a data agent:

- Gemini Data Analytics Stateless Chat User
(
`roles/geminidataanalytics.dataAgentStatelessUser`

). - BigQuery Data Viewer (
`roles/bigquery.dataViewer`

) on any table that the data agent uses as a knowledge source. - Dataplex Catalog Viewer (
`roles/datacatalog.catalogViewer`

) on the project - If a data table uses
[column-level access control](https://docs.cloud.google.com/bigquery/docs/column-level-security-intro), Fine-Grained Reader (`roles/datacatalog.categoryFineGrainedReader`

) on the appropriate policy tag. For more information, see[Roles used with column-level access control](https://docs.cloud.google.com/bigquery/docs/column-level-security-intro#roles). - If a data table uses
[row-level access control](https://docs.cloud.google.com/bigquery/docs/row-level-security-intro), you must have the row-level access policy on that table. For more information, see[Create or update row-level access policies](https://docs.cloud.google.com/bigquery/docs/managing-row-level-security#create-policy). - If a data table uses
[data masking](https://docs.cloud.google.com/bigquery/docs/column-data-masking-intro), Masked Reader (`roles/bigquerydatapolicy.maskedReader`

) on the appropriate data policy. For more information, see[Roles for querying masked data](https://docs.cloud.google.com/bigquery/docs/column-data-masking-intro#roles_for_querying_masked_data).

To work with BigQuery resources, such as viewing tables or
running queries, see [BigQuery
roles](https://docs.cloud.google.com/bigquery/docs/access-control#bigquery-roles).

## Best practices

When using conversational analytics, queries are automatically run to answer your questions. You might incur unforeseen charges in the following cases:

- If your tables are large
- If the queries use data joins
- If the queries make a lot of calls to AI functions

To prevent this issue, consider size when selecting knowledge sources, and when having conversations, consider using joins.

### Generate insights

You can optionally [generate data insights](https://docs.cloud.google.com/dataplex/docs/data-insights) in
Dataplex Universal Catalog for any table that you want to use as a knowledge
source.

Generated insights provide table metadata that the data agent can use to help generate responses to your questions.

If you don't generate insights beforehand, the system automatically generates them when you select a table as a knowledge source while creating a data agent.

## Work with the sample data agent

If you're unfamiliar with configuring agents for conversational analytics, you can optionally view the predefined sample agent generated for every Google Cloud project. You can chat with it and view its parameters to see how it was created, but you can't modify it.

To view the sample agent, do the following:

In the Google Cloud console, go to the BigQuery

**Agents**page.Select the

**Agent catalog**tab.Under the section

**Sample agents by Google**, click the sample agent card.

## Create a data agent

The following sections describe how to create a data agent.

After you create an agent, you can [edit its settings](https://docs.cloud.google.com#edit-agent).

### Configure basics

In the Google Cloud console, go to the BigQuery

**Agents**page.Select the

**Agent catalog**tab.Click

**New agent**. The**New agent**page opens.In the

**Editor**section, in the**Agent name**field, type a descriptive name for the data agent—for example,`Q4 sales data`

or`User activity logs`

.In the

**Agent description**field, type a description of the data agent. A good description explains what the agent does, what data it uses, and helps you know when this is the right data agent to chat with—for example,`Ask questions about customer orders and revenue`

.In the

**Knowledge sources**section, click**Add source**. The**Add knowledge source**page opens.In the

**Recents**section, select any tables, views, or UDFs that you want to use as knowledge sources. UDFs are prefixed with an 'fx' indicator in the Google Cloud console.To view additional knowledge sources, select

**Show more**.Optional: Add a knowledge source that isn't listed in the

**Recents**section:In the

**Search**section, type the source name into the**Search for tables**field, and then press**Enter**. The source name doesn't need to be exact.In the

**Search results**section, select one or more sources.

Click

**Add**. The new agent page reopens.

#### Customize table and field descriptions

To improve data agent accuracy, you can optionally provide additional table metadata. Only the data agent uses this metadata, and it doesn't affect the source table.

Follow these best practices when you create a table and field descriptions:

Use these descriptions as a guide to understand how the data agent understands the schema. If the descriptions suggested by the agent are correct, you can accept them.

If the data agent doesn't show an understanding of the schema after you configure these descriptions, then manually adjust the descriptions to provide the correct information.


Follow these steps to configure table and field descriptions:

In the

**Knowledge sources**section, click the**Customize**link for a table.Create a table description. You can type a description in the

**Table Description**field or accept the suggestion from Gemini.In the

**Fields**section, review the Gemini-suggested field descriptions.Select any field descriptions that you want to accept and click

**Accept suggestions**. Select any descriptions that you want to reject and click**Reject suggestions**.Manually edit any field description by clicking edit

**Edit**next to the field. The**Edit field**pane opens.- In the
**Description**field, type a field description. - To save the field description, click
**Update**.

- In the
To save the description and field updates, click

**Update**. The new agent page reopens.Repeat these steps for each table that needs customization.


### Configure advanced features

Configure optional advanced features such as agent instructions, verified
queries (previously known as *golden queries*), BigQuery custom
glossary terms, and agent settings. You can also review business glossary terms
imported from Dataplex Universal Catalog.

#### Create agent instructions

The agent should understand context for user questions without needing any custom instructions. Create custom instructions for the agent only if you need to change the agent's behavior or improve the context in ways that aren't already supported by other context features—for example, custom table and field metadata, or verified queries.

In the **Instructions** section, type instructions for the data agent in the
**Agent instructions** field. Because the data agent uses these instructions to
understand the context for user questions and to provide answers, make the
instructions as clear as possible.

If you don't get a satisfactory answer from the agent, then add structured context such as descriptions, examples or glossary terms. If you still don't get a satisfactory answer, add custom instructions like the examples in the following table.

For even more examples of instructions, click **Show examples**.

| Information type | Description | Examples |
|---|---|---|
| Key fields | The most important fields for analysis. | "The most important fields in this table are: Customer ID, Product ID, Order Date." |
| Filtering and grouping | Fields that the agent should use to filter and group data. | "When a question is about a timeline or 'over time,' always use the order_created_date column." "When someone says 'by product,' group by the product_category column." |
| Default filtering | Fields to filter on by default. | "Unless stated otherwise, always filter the data on order_status = 'Complete'." |
| Synonyms and business terms | Alternative terms for key fields. | "If someone asks about 'Revenue' or 'Sales', use the total_sale_amount column." "We consider 'loyal' customers to be those with purchase_count > 5." |
| Excluded fields | Fields that the data agent should avoid using. | "Never use these fields: Transaction Date Derived, City Derived." |
| Join relationships | How two or more tables are related to each other, and which columns are used to join them. The agent must use standard SQL JOINs on column pairs to combine data. See the example column. | Customer Activity
|

#### Create verified queries

An agent uses verified queries in two ways:

- If an agent can use a verified query to answer a question that you ask it, to ensure a trustworthy answer, the agent invokes the query exactly as written.
- If the agent can't use the verified query to answer a question, it still uses the query as a reference to understand the data and the best practices for querying it.

You can select verified queries from a list generated by the system, or create your own.

To create a verified query for the data agent, formerly known as a
*golden query*, do the following:

Select one or more Gemini-suggested verified queries:

- In the
**Verified Queries**section, click**Review suggestions**. The**Review suggested verified queries**page opens. - Review the suggested verified queries. Select any that apply to your use case.
- Click
**Add**. The new agent page reopens.

- In the
To create your own verified query, click

**Add query**. The**Add verified query**page opens.- In the
**Question**field, type the user question that the verified query answers. - Click
**Generate SQL**to have Gemini generate a verified query that corresponds to the user question that you specified. - Modify the verified query if you choose.
- Click
**Run**and verify that the query returns the results that you expect. - Click
**Add**. The new agent page reopens.

- In the
Repeat these steps as needed to create additional verified queries.


#### Create or review glossary terms

You can create BigQuery custom glossary terms local to an agent, or review business glossary terms imported from Dataplex Universal Catalog that apply to the knowledge sources that you selected for an agent.

- Because business glossary terms from Dataplex Universal Catalog apply globally to
BigQuery resources, if you use Dataplex Universal Catalog,
[create and manage](https://docs.cloud.google.com/dataplex/docs/manage-glossaries)business glossary terms in Dataplex Universal Catalog instead of for individual agents. - If you need to modify business glossary terms imported from Dataplex Universal Catalog, you must edit them in Dataplex Universal Catalog and return to conversational analytics to see them.
- BigQuery custom glossary terms stay in BigQuery. They don't appear in Dataplex Universal Catalog.
- If you're not using Dataplex Universal Catalog, you can create BigQuery custom glossary terms for terms that you need to define for a specific agent.

Follow these steps to create custom glossary terms for an agent:

- In the
**Glossary**section of the agent**Editor**page, click**Add term**. - In the
**Custom terms**section, you can edit or delete any existing custom terms. - To create one or more new terms, click
**Create term**.- Enter a
**Term**, a**Definition**, and one or more**Synonyms**separated by a comma. - To create the term, click
**Add**. - If you want to delete the new term, click
**Delete**.

- Enter a
- To create more custom terms, repeat these steps.

Follow these steps to view business glossary terms imported from Dataplex Universal Catalog:

- In the
**Glossary**section of the agent**Editor**page, click**Add term**. - Navigate to the page section called
**Imported from Dataplex Universal Catalog**. - To modify imported terms in Dataplex Universal Catalog, you must click the link "Go to Dataplex Universal Catalog glossaries."
- After you've modified the terms in Dataplex Universal Catalog, you can
return to the agent
**Editor**page to view the modified terms.

#### Configure settings

In the **Settings** section, you can configure the following optional settings:

Create

[labels](https://docs.cloud.google.com/bigquery/docs/labels-intro)to help you organize your Google Cloud resources. Labels are key-value pairs that let you group related objects together or with other Google Cloud resources.- In the
**Settings**section, click**Manage labels**. - Click
**Add label**. - In the
**key**and**value**fields, enter your key-value pair for the label. - If you want to add more labels, click
**Add label**again. - To delete a label, click
**Delete**. - When you're finished, click
**Add**. The new agent page reopens.

- In the
Optional: Set a size limit for the queries processed by the data agent. In the

**Settings**section, type a value in the**Maximum bytes billed**field. You must set this limit to`10485760`

or higher, otherwise you receive the following error message:

```
Value error. In BigQuery on-demand pricing charges are
rounded up to the nearest MB, with a minimum of 10 MB of data processed
per query. So, max bytes billed must be set to greater or equal to
10485760.
```


If you don't specify a value, `maximum bytes billed`

defaults to the
project's [query usage per day quota](https://docs.cloud.google.com/bigquery/quotas#query_jobs). The
usage per day quota is unlimited unless you have specified a [custom
quota](https://docs.cloud.google.com/bigquery/docs/custom-quotas).

Continue to the next section to place the agent in draft mode or publish the agent.

### Preview and publish the agent

In the

**Preview**section, type an example user question in the**Ask a question**field, and then press**Enter**. To verify that the data agent returns the data that you expect, review the agent's response. If the response is not what you expect, change the settings in the**Editor**section to refine the data agent configuration until you get satisfactory responses. You can continue to test and modify your agent to refine the agent's results.Click

**Save**.To place the data agent in draft mode, which you can re-edit later, click

**Go back**to return to the**Agent Catalog**page. Because your agent is now in draft mode, it appears in the**My draft agents**section on the**Agent Catalog**tab.To publish your agent, remain on the agent creation page and proceed to the next step.

Click

**Publish**to publish the data agent and make it available for use in the project. You can create conversations with the data agent by using BigQuery Studio, and[by using Looker Studio Pro](https://docs.cloud.google.com/looker/docs/studio/conversational-data-agents#start-a-conversation-with-an-agent)if you have a[Looker Studio subscription](https://docs.cloud.google.com/looker/docs/studio/about-looker-studio-pro#how-to-get-looker-studio-pro). You can also build your own interface to chat with the data agent by using the Conversational Analytics API.Optional: In the

**Your agent has been published**dialog, click**Share**to share the data agent with other users.In the

**Share permissions**pane, click**Add principal**.In the

**New principals**field, enter one or more principals.Click the

**Select a role**list.In the

**Role**list, select one of the following roles:- Gemini Data Analytics Data Agent User
(
`roles/geminidataanalytics.dataAgentUser`

): grants permission to chat with the data agent. - Gemini Data Analytics Data Agent Editor
(
`roles/geminidataanalytics.dataAgentEditor`

): grants permission to edit the data agent. - Gemini Data Analytics Data Agent Viewer
(
`roles/geminidataanalytics.dataAgentViewer`

): grants permission to view the data agent.

- Gemini Data Analytics Data Agent User
(

Click

**Save**.To return to the new agent page, click

**Close**. Immediately after saving or publishing your agent, you can see it in the**Agent Catalog**.

## Manage data agents

You can find existing agents in the **Agent Catalog** tab, which consists of
three sections:

**My agents**: a list of all agents that you create and publish. You can modify and share published agents with others.**My draft agents**: agents that you haven't published yet. You can't share draft agents.**Shared by others in your organization**: Agents that others create and share with you. If others grant you permissions, you can edit these shared agents.

### Edit a data agent

Follow these steps to edit a data agent:

Go to the BigQuery

**Agents**page.Select the

**Agent Catalog**tab.Locate the agent card of the data agent that you want to modify.

To open the data agent in the agent editor, click

**Open actions**> click**Edit**on the agent card.Edit the data agent's configuration as needed.

To save your changes without publishing, click

**Save**.To publish your changes, click

**Publish**. In the**Share**dialog, you can either[share](https://docs.cloud.google.com#share-a-data-agent)the agent with others, or click**Cancel**.To return to the

**Agents**pane, click**Go back**.

### Share a data agent

Follow these steps to share a published data agent. You can't share draft agents.

Go to the BigQuery

**Agents**page.Select the

**Agent Catalog**tab.Locate the agent card of the data agent that you want to modify.

To open the data agent in the agent editor, click

**Open actions**> click**Edit**on the agent card.To share the data agent with other users, click

**Share**.In the

**Share permissions**pane, click**Add principal**.In the

**New principals**field, enter one or more principals.Click the

**Select a role**list.In the

**Role**list, select one of the following roles:- Gemini Data Analytics Data Agent User
(
`roles/geminidataanalytics.dataAgentUser`

): gives permission to chat with the data agent. - Gemini Data Analytics Data Agent Editor
(
`roles/geminidataanalytics.dataAgentEditor`

): gives permission to edit the data agent. - Gemini Data Analytics Data Agent Viewer
(
`roles/geminidataanalytics.dataAgentViewer`

): gives permission to view the data agent.

- Gemini Data Analytics Data Agent User
(
Click

**Save**.To return to the agent editing page, click

**Close**.To return to the

**Agents**pane, click**Go back**.

### Delete a data agent

Go to the BigQuery

**Agents**page.Select the

**Agent Catalog**tab.In either the

**My agents**or**My draft agents**section of the**Agent Catalog**tab, locate the agent card of the data agent that you want to delete.Click

**Open actions**>**Delete**.In the

**Delete agent?**dialog, click**Delete**.

## Locations

Conversational analytics operates globally; you can't choose which region to use.

## What's next

- Learn more about
[conversational analytics in BigQuery](https://docs.cloud.google.com/bigquery/docs/ca/conversational-analytics). - Learn more about the
[Conversational Analytics API](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/overview). [Analyze data with conversations](https://docs.cloud.google.com/bigquery/docs/ca/create-conversations).- Learn more about how the
[Gemini Data Analytics Data Agent Viewer (](https://docs.cloud.google.com/gemini/docs/conversational-analytics-api/access-control#predefined-roles)role gives permission to view the data agent.`roles/geminidataanalytics.dataAgentViewer`

)