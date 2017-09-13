export default function Link (props) {
  const {url} = props.contentState.getEntity(props.entityKey).getData();
  return (
    <a href={url} style={linkStyle}>
      {props.children}
    </a>
  );
};

const linkStyle = {
    color: '#3b5998',
    textDecoration: 'underline',
}

