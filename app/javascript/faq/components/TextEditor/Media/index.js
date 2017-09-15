export default function Media (props) {
  const entity = props.contentState.getEntity(
    props.block.getEntityAt(0)
  );
  const {src} = entity.getData();
  const type = entity.getType();
  let media = null;

  if (type === 'video' || type === 'image' || type === 'pagePush')  {
    media = <p>{src}</p>;
  }

  return media;
};

const Audio = (props) => {
  return <audio controls src={props.src} style={styles.media} />;
};

const Image = (props) => {
  return <p>{props.src} </p>;
};

const Video = (props) => {
  return <p>{props.src} </p>;
};

const styles = {
      media: {
        width: '100%',
        // Fix an issue with Firefox rendering video controls
        // with 'pre-wrap' white-space
        whiteSpace: 'initial'
      },
};


export { Audio, Image, Video };
