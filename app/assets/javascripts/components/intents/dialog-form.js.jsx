var DialogForm = React.createClass({
  id: 'dialog-form',

  getInitialState() {
    return {
      'unresolved-field': [{id: 1}],
      'missing-field': [{id: 1}],
      'present-field': [{id: 1}],
      'awaiting-field': [{id: 1}]
    };
  },

  propTypes: {
  },

  addRow(key){
    var currentState = this.state;
    var currentKey = currentState[key];

    currentKey.push({id: currentKey[currentKey.length - 1].id + 1});

    this.setState(currentState);
  },

  deleteRow(input, key){
    var newState = this.state[key];
    newState.splice(newState.indexOf(input), 1)

    this.setState(this.state);
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

    var present = [
      form.find( 'select[name="present-field"]' ).val() ,
      form.find( 'input[name="present-value"]'  ).val()
    ]

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
    var inputs = [
      {
        name: 'unresolved-field',
        title: 'is unresolved'
      },
      {
        name: 'missing-field',
        title: 'is missing'
      },
      {
        name: 'present-field',
        title: 'is present',
        hasInput: true,
        inputPlaceholder: 'present value',
        inputName: 'present-value'
      },
      {
        name: 'awaiting-field',
        title: 'Awaiting field'
      }
    ];

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
              {this.state['unresolved-field'].map(function(input, index){
                return(
                  <DialogSelectBox
                    key={input.id}
                    index={input.id}
                    fields={this.props.fields}
                    name='unresolved-field'
                    title='is unresolved'
                    addRow={this.addRow}
                    deleteRow={this.deleteRow.bind(this, input, 'unresolved-field')}
                  ></DialogSelectBox>
                );
              }.bind(this))}
              {this.state['missing-field'].map(function(input, index){
                return(
                  <DialogSelectBox
                    key={input.id}
                    index={input.id}
                    fields={this.props.fields}
                    name='missing-field'
                    title='is missing'
                    addRow={this.addRow}
                    deleteRow={this.deleteRow.bind(this, input, 'missing-field')}
                  ></DialogSelectBox>
                );
              }.bind(this))}
              {this.state['present-field'].map(function(input, index){
                return(
                  <DialogSelectBox
                    key={input.id}
                    index={input.id}
                    fields={this.props.fields}
                    name='present-field'
                    title='is present'
                    addRow={this.addRow}
                    deleteRow={this.deleteRow.bind(this, input, 'present-field')}
                    hasInput={true}
                    inputName='present-value'
                    inputPlaceholder='present value'
                  ></DialogSelectBox>
                );
              }.bind(this))}
              {this.state['awaiting-field'].map(function(input, index){
                return(
                  <DialogSelectBox
                    key={input.id}
                    index={input.id}
                    fields={this.props.fields}
                    name='awaiting-field'
                    title='Awaiting field'
                    addRow={this.addRow}
                    deleteRow={this.deleteRow.bind(this, input, 'awaiting-field')}
                  ></DialogSelectBox>
                );
              }.bind(this))}
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
