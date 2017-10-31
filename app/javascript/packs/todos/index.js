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

document.addEventListener('keydown', event => {
  const { target, keyCode } = event;
  const { behavior } = target.dataset;
  const filter = document.querySelector('.filter.selected').innerText;
  const li = findListItem(target);
  let { id, title, completed } = li.dataset || {};

  switch(keyCode) {
    case ENTER_KEY:
      switch(behavior) {
        case 'create':
          return send(behavior, { title: target.value, filter });
        case 'update':
          return send(behavior, { id, completed, title: target.value, filter });
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
  const filter = document.querySelector('.filter.selected').innerText;
  const li = findListItem(target);
  let { id, title, completed } = li.dataset || {};

  switch(behavior) {
    case 'toggle-all':
      event.preventDefault();
      const updates = document.getElementsByTagName('li').reduce((memo, li) => {
        completed = (completed === 'true' ? false : true);
        if (title) memo.push({id, title, completed, filter});
      }, []);
      return send('update', updates);

    case 'toggle':
      event.preventDefault();
      completed = (completed === 'true' ? false : true);
      return send('update', { id, title, completed, filter });

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
