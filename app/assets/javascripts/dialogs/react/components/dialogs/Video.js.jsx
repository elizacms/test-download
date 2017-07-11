var Video = React.createClass({
  getInitialState() {
    return {
      thumbnail: "",
      url: ""
    };
  },

  componentDidMount() {
    if (this.props.value.video){
      this.setState({
        thumbnail: this.props.value.video.thumbnail,
        url: this.props.value.video.url
      });
    } else {
      this.getInitialState();
    }
  },

  componentWillReceiveProps(nextProps) {
    if (nextProps.value.video) {
      this.setState({
        thumbnail: nextProps.value.video.thumbnail,
        url: nextProps.value.video.url
      });
    } else {
      this.getInitialState();
    }
  },

  handleInputChange(event) {
    const stateKey = event.target.name;

    this.setState({
      [stateKey]: event.target.value
    }, () => { //Update parent after setState
      this.props.componentData( {video: this.state} );
    });
  },

  render() {
    return(
      <div>
        <label>
          <span className='dialog-label'>Video Thumbnail</span>
        </label>
        <input
          className='dialog-input'
          type='text'
          name='thumbnail'
          placeholder="Thumbnail"
          value={this.state.thumbnail}
          onChange={this.handleInputChange}
        />
        <label>
          <span className='dialog-label'>Video URL</span>
        </label>
        <input
          className='dialog-input abs-position'
          type='text'
          name='url'
          placeholder="Link"
          value={this.state.url}
          onChange={this.handleInputChange}
        />
        <br />
      </div>
    );
  }
});