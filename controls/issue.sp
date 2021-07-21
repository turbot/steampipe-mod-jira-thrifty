benchmark "issue_best_practices" {
  title = "Issue Best Practices"
  description = "Best practices for your issues."
  children = [
    control.issue_has_assignee,
    control.issue_has_labels,
    control.issue_older_30_days,
    control.issue_over_duedate,
    control.issue_with_epic,
    control.issue_time_tracking_enabled,
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

control "issue_time_tracking_enabled" {
  title = "Time tracking should be enabled for each issue"
  description = "Issue time tracking should be enabled for as time tracking lets your team record the time they spend working on issue."

  sql = <<-EOT
    select
      time_tracking_enabled as resource,
      case
        when time_tracking_enabled then 'ok'
        else 'alarm'
      end as status,
      case
        when time_tracking_enabled then 'Time tracking enabled for each issue.'
        else 'Time tracking not enabled for each issue.'
      end as reason,
      time_tracking_enabled
    from
      jira_global_setting;
  EOT

  tags = local.sherlock_common_tags
}