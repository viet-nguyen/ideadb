
class Ideadb.Views.Ideas.FilterView extends Backbone.View
  template: JST["backbone/templates/ideas/filter"]

  events:
    'keyup #search_query': 'searchKeyPress'
    'focus #search_query': 'lockUpdates'
    'blur #search_query': 'unlockUpdates'
    'click .rm-tag': 'removeTag'
    'click #reset-filter': 'resetFilter'

  filter_settings:
    tag: []
    title: ''

  locked: false

  initialize: () ->
    window.Ideadb.Application.vent.on 'filter_changed', (new_settings) =>
      unless @locked
        @filter_settings = new_settings
        @render()

  render: () ->
    @filter_settings.tag = [] unless @filter_settings.tag
    @filter_settings.title = '' unless @filter_settings.title
    @.$el.html @template @filter_settings
    @$('#search_query').val @filter_settings.title

  searchKeyPress: (e) ->
    window.Ideadb.Application.vent.trigger 'add_filter',
      title: @$('#search_query').val()

  lockUpdates: () ->
    @locked = true

  unlockUpdates: () ->
    @locked = false

  removeTag: (e) ->
    e.preventDefault()
    window.Ideadb.Application.vent.trigger 'remove_filter',
      tag: $(e.target).data('tag')

  resetFilter: (e) ->
    e.preventDefault()
    window.Ideadb.Application.vent.trigger 'reset_filter'
