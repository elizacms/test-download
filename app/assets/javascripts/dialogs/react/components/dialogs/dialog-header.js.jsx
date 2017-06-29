var DialogHeader = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  intentName() {
    return this.props['intent_name']
  },

  skillName() {
    return this.props['skill_name']
  },

  webHook() {
    return this.props['web_hook']
  },


  render() {
    return (
      <div className='dialogHeader'>
        <div className='info-header'>
          <div>
            <strong>Skill: </strong>{this.skillName()}
          </div>
          <div>
            <strong>Intent: </strong>{this.intentName()}
          </div>
          <div>
            <strong>Webhook: </strong>{this.webHook()}
          </div>
        </div>

        <hr className='margin0'></hr>
      </div>
    );
  }
});
