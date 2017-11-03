import 'todomvc-common/base.css';
import 'todomvc-app-css/index.css';

CableReady.debug = false;

const ENTER_KEY = 13;
const ESCAPE_KEY = 27;

function findListItem(element) {
  if (!element || element === document.body) return {};
  if (element.tagName === 'LI') return element;
  return findListItem(element.parentElement);
}

function selectedFilter () {
  const element = document.querySelector('.filter.selected');
  return element ? element.dataset.behavior.replace(/^show-/, '') : 'all';
}

function send(operation, filter, params={}) {
  App.todo.send({
    operation: { name: operation, params },
    filter
  });
}

document.addEventListener('keydown', event => {
  const { target, keyCode } = event;
  const { behavior } = target.dataset;
  const li = findListItem(target);
  let { id, title, completed } = li.dataset || {};

  switch(keyCode) {
    case ENTER_KEY:
      switch(behavior) {
        case 'create':
          return send(behavior, selectedFilter(), { title: target.value });
        case 'update':
          return send(behavior, selectedFilter(), { id, completed, title: target.value });
      }
      break;
    case ESCAPE_KEY:
      if ('update') return send('show', selectedFilter(), { id });
      break;
  }
});

document.addEventListener('dblclick', event => {
  const { target } = event;
  const { behavior } = target.dataset;
  const li = findListItem(target);
  let { id, title, completed } = li.dataset || {};
  if (behavior == 'edit') return send(behavior, selectedFilter(), { id });
});

document.addEventListener('click', event => {
  const { target } = event;
  const { behavior } = target.dataset;
  const li = findListItem(target);
  let { id, title, completed } = li.dataset || {};

  switch(behavior) {
    case 'toggle-all':
      event.preventDefault();
      return send('update', selectedFilter(), { id: 'toggle' });

    case 'toggle':
      event.preventDefault();
      completed = (completed === 'true' ? false : true);
      return send('update', selectedFilter(), { id, title, completed });

    case 'destroy-completed':
      event.preventDefault();
      return send('destroy', selectedFilter(), { id: 'completed' });

    case 'destroy':
      event.preventDefault();
      return send('destroy', selectedFilter(), { id });

    case 'show-all':
      event.preventDefault();
      return send('index', 'all');

    case 'show-uncompleted':
      event.preventDefault();
      return send('index', 'uncompleted');

    case 'show-completed':
      event.preventDefault();
      return send('index', 'completed');
  }
});
