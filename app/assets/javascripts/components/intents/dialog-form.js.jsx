var DialogForm = React.createClass({
  id: 'dialog-form',

  propTypes: {
  },

  createDialog(e){
    e.preventDefault();
    var data = {};
    var form = $('form');

    data[ 'intent_id'  ] = form.find( 'input[name="intent-id"]'         ).val();
    data[ 'priority'   ] = form.find( 'input[name="priority"]'          ).val();
    data[ 'response'   ] = form.find( 'input[name="response"]'          ).val();
    data[ 'unresolved' ] = form.find( 'select[name="unresolved-field"]' ).val();
    data[ 'missing'    ] = form.find( 'select[name="missing-field"]'    ).val();

    var present = [ form.find( 'select[name="present-field"]' ).val() ,
                    form.find( 'input[name="present-value"]'  ).val() ]
    data[ 'present' ] = present;

    data[ 'awaiting_field' ] = form.find( 'select[name="awaiting-field"]' ).val();

    if ( $('.aneeda-says').val().replace( /\s/g, '' ) == '' ){
      this.props.messageState({'aneeda-says-error': 'This field cannot be blank.'});

      return false;
    }

    this.props.createDialog(data);
  },

  componentDidUpdate() {
  },

  render: function() {
    var field_options = (
      this.props.fields.map(function(field, index){
        return <option key={index}>{field}</option>;
      }.bind(this))
    );

    return (
      <div>
        <h4 className='inline'>Fields</h4>
        <a href={this.props.field_path} className='addField btn md grey pull-right'>Add a field</a>
        <form className='dialog' method='post' action='/dialogue_api/response'>
          <input type='hidden' name='intent-id' value={this.props.intent_id}>
          </input>
          <hr className='margin5050'></hr>

          <div className='row'>
            <strong className='two columns margin0'>Priority</strong>
            <input name='priority' type='number' className='three columns priority-input'>
            </input>
          </div>

          <hr className='margin-15'></hr>

          <div className='row'>
            <strong className='two columns margin0'>Aneeda Says</strong>
            <input className='aneeda-says two columns' name='response' type='text' placeholder='ex: Please log into your account' >
            </input>
          </div>

          <DialogMessage message={this.props.response} name='aneeda-says-error'>
          </DialogMessage>
          <hr className='margin0'></hr>

          <table className='dialog'>
            <tbody>
              <DialogSelectBox
                fields={this.props.fields}
                name='unresolved-field'
                title='is unresolved'
              ></DialogSelectBox>

              <DialogSelectBox
                fields={this.props.fields}
                name='missing-field'
                title='is missing'
              ></DialogSelectBox>

              <DialogSelectAndInput
                title='is present'
                fields={this.props.fields}
                name='present-field'
                inputName='present-value'
                inputPlaceholder='present value'
              ></DialogSelectAndInput>

              <DialogSelectBox
                fields={this.props.fields}
                name='awaiting-field'
                title='Awaiting Field'
              ></DialogSelectBox>
            </tbody>
          </table>

          <button
            onClick={this.createDialog}
            className='btn lg ghost dialog-btn pull-right'
          >Create Dialog</button> &nbsp;
        </form>
      </div>
    );
  }
});
