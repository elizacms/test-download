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
      <div>
        <div className='row'>
          <div className='col-xs-3 info-header'>
            <strong>Skill: </strong>{this.skillName()}
          </div>
          <div className='col-xs-4 info-header'>
            <strong>Intent: </strong>{this.intentID()}
          </div>
          <div className='col-xs-3 info-header'>
            <strong>Webhook: </strong>{this.webHook()}
          </div>
          <div className='col-xs-2 pull-right'>
            <button onClick={this.getCSV} className='btn lg ghost export-csv pull-right'>
              Export CSV
            </button>
          </div>
        </div>

        <hr className='margin0'></hr>
      </div>
    );
  }
});
