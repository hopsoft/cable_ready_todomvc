import 'todomvc-common/base.css';
import 'todomvc-app-css/index.css';

CableReady.debug = true;

const ENTER_KEY = 13;
const ESCAPE_KEY = 27;

function findListItem(element) {
  if (!element || element === document.body) return {};
  if (element.tagName === 'LI') return element;
  return findListItem(element.parentElement);
}

function send(action, params) {
  if (!Array.isArray(params)) params = [params];
  App.todo.send({ [action]: params });
}

function activeFilter () {
  const element = document.querySelector('.filter.selected');
  if (element) {
    return element.dataset.behavior.replace(/^show-/, '');
  }
  return 'all';
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
          return send(behavior, { title: target.value, filter: activeFilter() });
        case 'update':
          return send(behavior, { id, completed, title: target.value, filter: activeFilter() });
      }
      break;
    case ESCAPE_KEY:
      if ('update') return send('show', { id });
      break;
  }
});

document.addEventListener('dblclick', event => {
  const { target } = event;
  const { behavior } = target.dataset;
  const li = findListItem(target);
  let { id, title, completed } = li.dataset || {};
  if (behavior == 'edit') return send(behavior, { id });
});

document.addEventListener('click', event => {
  const { target } = event;
  const { behavior } = target.dataset;
  const li = findListItem(target);
  let { id, title, completed } = li.dataset || {};

  switch(behavior) {
    case 'toggle-all':
      event.preventDefault();
      return send('update', { id: 'toggle' });

    case 'toggle':
      event.preventDefault();
      completed = (completed === 'true' ? false : true);
      return send('update', { id, title, completed, filter: activeFilter() });

    case 'destroy-completed':
      event.preventDefault();
      return send('destroy', { id: 'completed' });

    case 'destroy':
      event.preventDefault();
      return send('destroy', { id });

    case 'show-all':
      event.preventDefault();
      return send('index', { filter: 'all' });

    case 'show-uncompleted':
      event.preventDefault();
      return send('index', { filter: 'uncompleted' });

    case 'show-completed':
      event.preventDefault();
      return send('index', { filter: 'completed' });
  }
});
