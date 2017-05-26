var Video = React.createClass({
  getInitialState() {
    return {
      videoThumbnail: "",
      videoEntity: ""
    };
  },

  componentDidMount() {
    this.setState({
      videoThumbnail: this.props.value.videoThumbnail || "",
      videoEntity: this.props.value.videoEntity || ""
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      videoThumbnail: nextProps.value.videoThumbnail || "",
      videoEntity: nextProps.value.videoEntity || ""
    });
  },

  handleInputChange(event) {
    const stateKey = event.target.name;

    this.setState({
      [stateKey]: event.target.value
    }, () => { //Update parent after setState
      this.props.componentData( this.state );
    });
  },

  render() {
    return(
      <div>
        <label>
          <span className='dialog-label'>Video</span>
        </label>
        <input
          className='dialog-input'
          type='text'
          name='videoThumbnail'
          placeholder="Thumbnail"
          value={this.state.videoThumbnail}
          onChange={this.handleInputChange}
        />
        <label>
          <span className='dialog-label video-label-right'>Entity Value</span>
        </label>
        <input
          className='dialog-input abs-position'
          type='text'
          name='videoEntity'
          placeholder="Link"
          value={this.state.videoEntity}
          onChange={this.handleInputChange}
        />
        <br />
      </div>
    );
  }
});