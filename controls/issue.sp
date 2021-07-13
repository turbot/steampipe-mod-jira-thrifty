locals {
  issue_common_tags = local.sherlock_common_tags
}

benchmark "issue_best_practices" {
  title = "Issue Best Practices"
  description = "Best practices for your issues."
  children = [
    control.issue_has_assignee,
    control.issue_has_labels,
    control.issue_older_30_days,
    control.issue_over_duedate,
    control.issue_with_epic,
    control.issue_with_no_duplicate_summary,
  ]
}

control "issue_over_duedate" {
  title = "Issues issue_over_duedate"
  description = "Issues should have at least 1 assignee so it's clear who is responsible for it."

  sql = <<-EOT
    select
      id as resource,
      case
        when duedate is null then 'info'
        when duedate > current_timestamp then 'ok'
        else 'alarm'
      end as status,
      case
        when duedate is null then title || ' has no duedate.'
        when duedate > current_timestamp then title || ' is not over duedate.'
        else id || ' is over duedate by ' || date_part('day', current_timestamp - duedate) || ' day(s).'
      end as reason,
      title
    from
      jira_issue
    where
      status <> 'Done';

  EOT

    tags = local.sherlock_common_tags
}

control "issue_has_assignee" {
  title = "Issues should have user assigned"
  description = "Issues should have assignee so it's clear who is responsible for it."

  sql = <<-EOT
    select
      id as resource,
      case
        when assignee_account_id is null then 'alarm'
        else 'ok'
      end as status,
      case
        when assignee_account_id is null then  '#' || id || ' ' || title || ' has no assignee.'
        else
        '#' || id || ' ' || title || ' has assignee.'
      end as reason,
      title
    from
      jira_issue
    where
      status <> 'Done';
  EOT

  tags = local.sherlock_common_tags
}

control "issue_older_30_days" {
  title = "Issues should not be open longer than 30 days"
  description = "Issues should be resolved or closed in a timely manner."

  sql = <<-EOT
    select
      id as resource,
      case
        when created <= (current_date - interval '30' day) then 'alarm'
        else 'ok'
      end as status,
      '#' || id || ' ' || title || ' created ' || to_char(created , 'DD-Mon-YYYY') ||
        ' (' || extract(day from current_timestamp - created) || ' days).' as reason,
      title
    from
      jira_issue
    where
      status <> 'Done';
  EOT

  tags = local.sherlock_common_tags
}

control "issue_has_labels" {
  title = "Issues should have labels applied"
  description = "Labels help organize issues and provide users with more context."

  sql = <<-EOT
    select
      id as resource,
      case
        when labels <> '[]' then 'ok'
        else 'alarm'
      end as status,
      '#' || id || ' ' || title || ' has ' || jsonb_array_length(labels) || ' label(s).' as reason,
      title
    from
      jira_issue
    where
      status <> 'Done';
  EOT

  tags = local.sherlock_common_tags
}

control "issue_with_no_duplicate_summary" {
  title = "Issue with no duplicate summary"
  description = "There are no duplicate summary for issues in project."

  sql = <<-EOT
    with duplicate_summary_count as (
      select
        count(id) as summary_count,
        project_id,
        summary
      from
        jira_issue
      where
        status <> 'Done'
      group by summary, project_id
    )
    select
      id as resource,
      case
        when c.summary_count > 1 then 'alarm'
        else 'ok'
      end as status,
      case
        when c.summary_count > 1 then 'Summary (' || c.summary || ') is repeated ' || c.summary_count || ' times.'
        else 'There is no duplicate summary.'
      end as reason,
      i.title
    from
      jira_project as i
      left join duplicate_summary_count as c on i.id = c.project_id
  EOT

  tags = local.sherlock_common_tags
}

control "issue_with_epic" {
  title = "Issue should have epic associated"
  description = "Issue should have epic key associated to which issue belongs."

  sql = <<-EOT
    select
      id as resource,
      case
        when epic_key is null then 'alarm'
        else 'ok'
      end as status,
      case
        when epic_key is null then  '#' || id || ' ' || title || ' has no epic key associated.'
        else '#' || id || ' ' || title || ' has epic key associated.'
      end as reason,
      title
    from
      jira_issue
    where
      status <> 'Done';
  EOT

  tags = local.sherlock_common_tags
}