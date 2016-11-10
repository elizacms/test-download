var DialogMessage = React.createClass({
  propTypes: {
  },

  messageText(){
    return this.props.message.hasOwnProperty(this.props.name) ?
      this.props.message[this.props.name] : '' ;
  },

  render: function() {
    return(<div className={this.props.name}>{this.messageText()}</div>);
  }
});
