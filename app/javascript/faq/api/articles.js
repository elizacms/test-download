
export function fetchArticles(page) {
  let apiUrl = '/api/articles';
  if(page) {
    apiUrl = `${apiUrl}?page=${page}`
  }
	return fetch(apiUrl)
		.then(response => response.json())
    .then(json => {
      console.log(json);
      return json;
    })
    .catch((err) => {
			console.log('error', err);
		});
}
