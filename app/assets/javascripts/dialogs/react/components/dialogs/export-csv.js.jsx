var ExportCSV = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  getCSV() {
    var intent_id = $( 'form' ).children( 'input[name="intent-id"]' ).val();

    window.location.assign( '/dialogue_api/csv?intent_id=' + this.props.intent_id );
  },

  intentID() {
    return this.props['intent_id']
  },

  skillName() {
    return this.props['skill_name']
  },

  webHook() {
    return this.props['web_hook']
  },


  render() {
    return (
      <div className='exportCSV'>
        <div className='info-header-button'>
          <button onClick={this.getCSV} className='btn lg ghost export-csv'>
            Export CSV
          </button>
        </div>
        <div className='info-header'>
          <div>
            <strong>Skill: </strong>{this.skillName()}
          </div>
          <div>
            <strong>Intent: </strong>{this.intentID()}
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
