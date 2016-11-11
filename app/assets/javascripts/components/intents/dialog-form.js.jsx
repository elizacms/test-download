var DialogForm = React.createClass({
  id: 'dialog-form',

  getInitialState() {
    return {
      'unresolved-field': [{id: 0, value: ''}],
      'missing-field':    [{id: 0, value: ''}],
      'present-field':    [{id: 0, value: ''}],
      'awaiting-field':   [{id: 0, value: ''}],
      priority: '',
      response: ''
    };
  },

  propTypes: {
  },

  // componentDidUpdate(prevProps, prevState) {
  //   debugger
  // },

  createNewId(rules, nextProps){
      var ary = [];

      if (nextProps.data[0][rules]) {
        nextProps.data[0][rules].forEach(function(value, index){
          ary.push({id: index, value: value});
        });

        return ary;
      } else {
        nextProps.data[0].responses[0][rules].forEach(function(value, index){
          ary.push({id: index, value: value});
        });

        return ary;
      }

      // added this because I couldn't save a new record, but it might be invalid. BT
      return [0];
  },

  componentWillReceiveProps(nextProps) {
    if(Object.keys(nextProps.data).length > 0) {
      console.log(nextProps.data[0]);
      this.setState({
        'unresolved-field': this.createNewId('unresolved', nextProps),
        'missing-field':    this.createNewId('missing', nextProps),
        'present-field':    this.createNewId('present', nextProps),
        'awaiting-field':   this.createNewId('awaiting_field', nextProps),
        priority:           nextProps.data[0].priority,
        response:           nextProps.data[0].responses[0].response,
      });
    }
  },

  checkData(){
    if (this.state.data.hasOwnProperty('responses')){
      return this.state.data.responses[0].response
    }
  },

  priorityHandleChange(event) {
    this.setState({ priority: event.target.value });
  },

  aneedaSaysHandleChange(event){
    this.setState({ response: event.target.value });
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

  parseFormInput(name, hasExtra){
    var ary = [];

   $('form').find( 'select[name="' + name + '-field"]' ).each(function(){
      ary.push($(this).val());
    });

    if (hasExtra){
      ary2 = [];
      $('form').find( 'input[name="' + name + '-value"]' ).each(function(index){
        ary2.push(ary[index]);
        ary2.push($(this).val());
      });
      return ary2;
    }

    return ary;
  },

  data(){
    if (this.props.data.length > 0){
      return this.props.data[0];
    }
    return {};
  },

  createDialog(e){
    e.preventDefault();
    var data = {};
    var form = $('form');

    data[ 'intent_id'  ] = form.find( 'input[name="intent-id"]'         ).val();
    data[ 'priority'   ] = form.find( 'input[name="priority"]'          ).val();
    data[ 'response'   ] = form.find( 'input[name="response"]'          ).val();

    data[ 'unresolved'     ] = this.parseFormInput('unresolved');
    data[ 'missing'        ] = this.parseFormInput('missing');
    data[ 'present'        ] = this.parseFormInput('present', true);
    data[ 'awaiting_field' ] = this.parseFormInput('awaiting');

    if ( $('.aneeda-says').val().replace( /\s/g, '' ) == '' ){
      this.props.messageState({'aneeda-says-error': 'This field cannot be blank.'});

      return false;
    }

    this.props.createDialog(data);
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
          <input type='hidden' name='intent-id' value={this.props.intent_id} />
          <hr className='margin5050'></hr>

          <div className='row'>
            <strong className='two columns margin0'>Priority</strong>
            <input
              className='three columns priority-input'
              name='priority'
              type='number'
              value={this.state.priority}
              onChange={this.priorityHandleChange} />
          </div>

          <hr className='margin-15'></hr>

          <div className='row'>
            <strong className='two columns margin0'>Aneeda Says</strong>
            <input
              className='aneeda-says two columns'
              name='response'
              type='text'
              placeholder='ex: Please log into your account'
              value={this.state.response}
              onChange={this.aneedaSaysHandleChange} />
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
                    value={this.state['unresolved-field'][input.id].value}
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
                    value={this.state['missing-field'][input.id].value}
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
                    value={this.state['present-field'][input.id].value}
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
                    value={this.state['awaiting-field'][input.id].value}
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
