Ideadb.Views.Ideas ||= {}

class Ideadb.Views.Ideas.IdeaView extends Backbone.Marionette.ItemView
  template: JST["backbone/templates/ideas/idea"]

  events: 
    'click .idea-title': 'makeTitleEditable'
    'click .remove': 'showRemoveModal'
    'click .remove-idea': 'removeIdea'
    'click .rm-tag': 'removeTag'
    'click .show-tag-add': 'showTagAdd'
    'click .show-comments': 'showComments'
    'blur .idea-title': 'finishedEditing'
    'keypress .tag-input': 'onTagKeyPress'

  initialize: () ->
    @known_tags = []
    window.Ideadb.Application.vent.on 'taglist_update', (taglist) =>
      @known_tags = taglist

    @comment_collection = new Ideadb.Collections.CommentsCollection [],
      idea: @model

    @comment_view = new Ideadb.Views.Ideas.CommentsView
      collection: @comment_collection

    @comments = false

  makeTitleEditable: (e) ->
    @$('.idea-title').attr 'contenteditable', 'true'
    @$('.idea-title').html @model.get('title')
    window.Ideadb.Application.vent.trigger 'lock_updates', true

  finishedEditing: () ->
    @$('.idea-title').attr 'contenteditable', 'false'
    @model.attributes.title = @$('.idea-title').html()
    @model.save()
    @render()
    window.Ideadb.Application.vent.trigger 'lock_updates', false

  showTagAdd: () ->
    @$('.tag-add-line').show()
    @$('.tag-input').focus()
    @.$('.tag-input').typeahead
      source: (query) =>
        return window.router.addView.known_tags.filter (t) -> t.toLowerCase().indexOf(query.toLowerCase()) != -1

  showRemoveModal: () ->
    @$('.remove-modal').modal('show')

  removeIdea: () ->
    @model.destroy()

  removeTag: (e) ->
    e.stopPropagation()
    @model.set 'tags', _.reject @model.get('tags'), (tag) -> tag.id == $(e.target).data('tag-id')
    @model.save()
    @render()

  onTagKeyPress: (e) ->
    if e.keyCode == 13
      val = @.$('.tag-input').val().trim()
      @.$('.tag-input').val ''
      if val.length
        unless _.find(@model.get('tags'), (t) -> t.name == val)
          @model.set 'tags', _.flatten [@model.get('tags'), {id: 0, name: val}]
          @model.save()
          @render()
      @$('.tag-add-line').hide()

  onRender: () ->
    if @comments
      @comment_collection.fetch()
      @$('.comments').html @comment_view.render().$el
      @$('.comments').show()

  showComments: (e) ->
    e.preventDefault()
    @comments = ! @comments
    @render()

