group_by(.labels.network)
| map({
  key: .[0].labels.network,
  value: map({
    (.name): {
      ansible_host: .networkInterfaces[0].accessConfigs[0].natIP,
      labels: .labels,
      private_ip_address: .networkInterfaces[0].networkIP,
      project: (.selfLink | split("/")[6]),
      zone: (.zone | split("/") | last),
    }
  }) | add
})
| map({key: .key, value: {hosts:.value}})
| from_entries
