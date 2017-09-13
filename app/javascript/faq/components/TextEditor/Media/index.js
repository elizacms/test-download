export default function Media (props) {
  const entity = props.contentState.getEntity(
    props.block.getEntityAt(0)
  );
  const {src} = entity.getData();
  const type = entity.getType();
  let media = null;
  if (type === 'audio') {
    media = <Audio src={src} />;
  }

  if (type === 'image') {
    media = <Image src={src} />;
  }

  if (type === 'video') {
    media = <Video src={src} />;
  }
  return media;
};

const Audio = (props) => {
  return <audio controls src={props.src} style={styles.media} />;
};

const Image = (props) => {
  return <img src={props.src} style={styles.media} title={props.src} alt={props.src} />;
};

const Video = (props) => {
  return <video controls src={props.src} style={styles.media} />;
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
