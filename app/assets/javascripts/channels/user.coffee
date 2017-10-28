App.user = App.cable.subscriptions.create { channel: "UserChannel", room: window.userId },
  received: (data) ->
    CableReady.perform(data.operations) if data.cableReady?
