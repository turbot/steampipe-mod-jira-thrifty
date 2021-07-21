benchmark "organization_best_practices" {
  title = "Organization Best Practices"
  description = "Best practices for your organizations."
  children = [
    control.organization_admin_group_max_3_members,
    control.organization_all_users_should_not_be_site_admins,
  ]
}

control "organization_admin_group_max_3_members" {
  title = "Organization admin group should have max 3 members"
  description = "Administration team should have maximum 3 members in order to reduce the potential for breach by a compromised owner."

  sql = <<-EOT
    select
      name as resource,
      case
        when member_ids is null then 'info'
        when jsonb_array_length(member_ids) > 3 then 'alarm'
        else 'ok'
      end as status,
      case
      when member_ids is null then 'No members attached.'
      else name || ' has ' || jsonb_array_length(member_ids) || ' member(s).'
      end as reason,
      title
    from
      jira_group
    where
      name ilike '%admin%';
  EOT

  tags = local.sherlock_common_tags
}

control "organization_all_users_should_not_be_site_admins" {
  title = "Organization all users should not be site_admins"
  description = "Organization all users should not be part of site_admins group as they have access to the site's administration and access to the products through this group."

  sql = <<-EOT
    with user_account_id as (
      select
        count(account_id) as total_users
      from
        jira_user
      where
        account_type = 'atlassian'
    )
    select
      g.name as resource,
      case
        when i.total_users = jsonb_array_length(member_ids) then 'alarm'
        else 'ok'
      end as status,
      jsonb_array_length(member_ids) || ' out of ' || i.total_users || ' users have site-admin access.' as reason
    from
      jira_group as g,
      user_account_id as i
    where
      g.name = 'site-admins';
  EOT

  tags = local.sherlock_common_tags
}