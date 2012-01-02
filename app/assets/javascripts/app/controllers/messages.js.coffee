$ = Spine.$
  
class App.Messages extends Spine.Controller
  className: 'messages'
  
  constructor: ->
    super
    @render()
    
  render: ->
    @append @aside = new App.Messages.Aside
    @append $('<div />').addClass('vdivide')
    @append @article = new App.Messages.Article
    
    @routes
      '/conversations/:id': (params) ->
        @active()
        @aside.active(params)
        @article.active(params)