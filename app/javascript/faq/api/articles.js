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
export function putArticle(article) {
  let urlWithPath = `${apiUrl}/${article.kbid}/`
  console.log(article);
  return fetch(urlWithPath, {
    method: 'PUT' ,
    headers: {
      'Content-type': 'application/json'
    },
    body: JSON.stringify(article)
  })
    .then(response => {
      console.log('put response', response);
      return response.json();
    })
    .then(json => {
      console.log('put json', json);
      return json;
    })
    .catch((err) => {
      console.log('error', err);
    });
}
