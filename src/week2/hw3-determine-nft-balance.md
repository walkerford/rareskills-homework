# How does a marketplace quickly determine a user's balance for a particular NFT?

In order to save on storage costs, contracts do not save this data explicitly, and therefore cannot generally offer a direct api to provide it. Instead, indexed events are used to leave a bread-crumb trail that is still fairly easy for the users follow.

Marketplaces' generally run their own full-nodes, or subscribe to a node provider, that then warehouses all of the events. This allows their backends to subscribe to updates or make queries about current state.
