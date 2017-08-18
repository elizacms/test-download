const API_ENDPOINT = `/api/articles`;

export function fetchArticles() {
	return fetch(API_ENDPOINT)
		.then(response => response.json())
    .then(json => {
      console.log(json);
      return json;
    })
    .catch((err) => {
			console.log('error', err);
		});
}
