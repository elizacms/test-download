var apiUrl = '/api/articles';

export function fetchArticles(page) {
  let urlWithQuery = apiUrl;
  if(page) {
    urlWithQuery = `${apiUrl}?page=${page}`
  }
  return fetch(urlWithQuery)
    .then(response => response.json())
    .then(json => {
      return json;
    })
    .catch((err) => {
      console.log('error', err);
    });
}


export function fetchSingleArticle(id) {
  let urlWithQuery = `${apiUrl}?kbid=${id}`
  return fetch(urlWithQuery)
    .then(response => response.json())
    .then(json => {
      return json;
    })
    .catch((err) => {
      console.log('error', err);
    });
}
