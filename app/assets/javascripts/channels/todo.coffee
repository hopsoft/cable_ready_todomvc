App.todo = App.cable.subscriptions.create { channel: "TodoChannel" },
  received: (data) ->
    CableReady.perform(data.operations) if data.cableReady?

