Resolutions = new Mongo.Collection("resolutions")

if Meteor.isClient

  Meteor.subscribe("resolutions")

  Template.body.helpers
    resolutions: ->
      if Session.get("hideFinished")
        return Resolutions.find(checked: $ne: true)
      else
        return Resolutions.find()

    hideFinished: ->
      return Session.get("hideFinished")

  Template.body.events
    "submit .new-resolution": (event) ->
      title = event.target.title.value
      Meteor.call("addResolution", title)
      event.target.title.value = ""
      return false

    "change .hide-finished": (event) ->
      Session.set("hideFinished", event.target.checked)

  Template.resolution.helpers
    isOwner: ->
      return this.owner == Meteor.userId()

  Template.resolution.events
    "click .toggle-checked": ->
      Meteor.call("updateResolution",this._id, !this.checked)
    "click .delete": ->
      Meteor.call("deleteResolution",this._id)
    "click .toggle-private": ->
      Meteor.call("setPrivate",this._id, !this.privat)

# end Meteor.isClient


if Meteor.isServer
  Meteor.publish "resolutions", ->
    return Resolutions.find
       $or: [
         privat: $ne: true
         owner: this.userId
       ]

Meteor.methods
  addResolution: (title) ->
    Resolutions.insert
       title: title
       createdAt: new Date()
       owner: Meteor.userId

  updateResolution: (id, checked) ->
    res = Resolutions.findOne(id)
    if res.owner != Meteor
      throw new Meteor.Error("not authorized")
    Resolutions.update(id, $set: checked: checked)

  deleteResolution: (id) ->
    res = Resolutions.findOne(id)
    if res.owner != Meteor
      throw new Meteor.Error("not authorized")
    Resolutions.remove(id)

  setPrivate: (id, checked) ->
    res = Resolutions.findOne(id)
    if res.owner != Meteor
      throw new Meteor.Error("not authorized")
    Resolutions.update(id, $set: privat: privat)



    #code to run on server at startup
