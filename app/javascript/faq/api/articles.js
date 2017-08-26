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


export function searchArticleByType(searchType, searchTerm) {
  let urlWithQuery = `${apiUrl}/search?search_type=${searchType}&input_text=${searchTerm}`
  return fetch(urlWithQuery, {
    method: 'GET' ,
    headers: {
      'Content-type': 'application/json'
    }
  })
    .then(response => {
      console.log('searchArticleByType response', response);
      return response.json();
    })
    .then(json => {
      console.log('searchArticleByType json', json);
      return json;
    })
    .catch((err) => {
      console.log('error', err);
    });
}

export function deleteArticle(kbid) {
  let urlWithPath = `${apiUrl}/${kbid}/`;

  return fetch(urlWithPath, {
    method: 'Delete',
  })
    .then(response => {
      console.log('delete response', response);
      debugger;
      return response.json();
    })
    .then(json => {
      console.log('delete json', json);
      return json;
    })
    .catch((err) => {
      console.log('error', err);
    });
}


