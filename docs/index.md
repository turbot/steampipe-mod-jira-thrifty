---
repository: "https://github.com/turbot/steampipe-mod-alicloud-thrifty"
---

# Alicloud Thrifty Mod

Be Thrifty on Alibaba Cloud! This mod checks for unused resources and opportunities to optimize your spend on Alibaba Cloud.

## References

[Alibaba Cloud](https://in.alibabacloud.com/) provides on-demand cloud computing platforms and APIs to authenticated customers on a metered pay-as-you-go basis or as subscription.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, and codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration.

## Documentation

- **[Benchmarks and controls →](https://hub.steampipe.io/mods/turbot/alicloud_thrifty/controls)**

## Get started

Install the Alicloud plugin with [Steampipe](https://steampipe.io):
```shell
steampipe plugin install alicloud
```

Clone:
```sh
git clone git@github.com:turbot/steampipe-mod-alicloud-thrifty
cd steampipe-mod-alicloud-thrifty
```

Run all benchmarks:
```shell
steampipe check all
```

Run a specific control:
```shell
steampipe check control.ecs_disk_large
```

### Credentials

This mod uses the credentials configured in the [Steampipe Alicloud plugin](https://hub.steampipe.io/plugins/turbot/alicloud).

### Configuration

No extra configuration is required.

## Get involved

* Contribute: [Help wanted issues](https://github.com/turbot/steampipe-mod-alicloud-thrifty/labels/help%20wanted)
* Community: [Slack channel](https://steampipe.slack.com/join/shared_invite/zt-oij778tv-lYyRTWOTMQYBVAbtPSWs3g#/shared-invite/email)