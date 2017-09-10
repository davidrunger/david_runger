### TODO
* groceries: fix formatting when item list is taller than screen (color stops at the viewport height)
* to clear the list, maybe popup a modal with a checklist (checkbox inputs) of items that were needed, and "Clear" button or whatever
* don't actually separate lists (!). yeah, just make un-needed items more transparent!
* add state to request locations
* cache/memoize IP addresses in the rake task -- no need to fetch same one multiple times
* make it so i can rapidly check off items (all checks are aligned)
* don't just have a naive boolean to track whether we are posting to the server -- it can be unset
  too quickly if there are simultaneous requests
  * instead, keep a count that track's how many pending requests there are
* listen for bad server responses
* "flash" an item in some way after creating it, so it's easier to visually confirm a successful add
* visually indicate which store is currently selected
* automatically linkify links
* allow editing of grocery items/stores
* track logged-out users (browser uuid or whatnot); consider Google Analytics or competitor
* privacy policy
* make the initially-displayed store be the store with the most recently updated item
* keyboard shortcut(s) for groceries -- mostly just one to jump to a list. also would be cool to
  increment items this way.
* use batch API http://ip-api.com/docs/api:batch
* install Rollbar Telemetry https://mail.google.com/mail/u/0/#inbox/15df68ae3f235b1d
* setup encryption
* resize and image_optim my profile pic

### DONE
* Vue.config.productionTip = false
* port home page to vue (so i can develop with total hot-reloading - HTML, JS, and CSS)
