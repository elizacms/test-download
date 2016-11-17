var DialogForm = React.createClass({
  id: 'dialog-form',

  getInitialState() {
    return this.initialData();
  },

  initialData(){
    return {
      'unresolved-field': [{id: 0, value: '', inputValue: ''}],
      'missing-field':    [{id: 0, value: '', inputValue: ''}],
      'present-field':    [{id: 0, value: '', inputValue: ''}],
      'awaiting-field':   [{id: 0, value: '', inputValue: ''}],
      priority: '',
      response: ''
    };
  },

  propTypes: {
  },

  createNewId(rules, nextProps){
    var ary = [];

    if (nextProps.data[rules]) {
      nextProps.data[rules].forEach(function(value, index){
        ary.push({id: index, value: value});
      });
    }

    return ary;
  },

  createNewIdForPresent(nextProps) {
    if (nextProps.data.present){
      var ary  = [];
      var ary2 = [];
      var res  = [];

      nextProps.data.present.forEach(function(value, index){
        index % 2 == 0 ? ary.push(value) : ary2.push(value);
      });

      ary.forEach(function(value, index){
        var hsh = {};
        hsh['id'] = index;
        hsh['value'] = value;
        hsh['inputValue'] = ary2[index];
        res.push(hsh);
      });

      return res;
    }
  },

  componentWillReceiveProps(nextProps) {
    if(Object.keys(nextProps.data).length > 0) {
      this.setState({
        'unresolved-field': this.createNewId('unresolved', nextProps),
        'missing-field':    this.createNewId('missing', nextProps),
        'present-field':    this.createNewIdForPresent(nextProps),
        'awaiting-field':   this.createNewId('awaiting_field', nextProps),
        priority:           nextProps.data.priority,
        response:           nextProps.data.response,
      });
    } else {
      this.setState(this.initialData());
      this.props.resetIsUpdateState();
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

    currentKey.push({
      id: currentKey[currentKey.length - 1].id + 1,
      value: '',
      inputValue: ''
    });

    this.setState(currentState);
  },

  deleteInput(input, key){
    var newState = this.state[key];
    newState.splice(newState.indexOf(input), 1)

    this.setState(this.state);
  },

  resetForm(e){
    e.preventDefault();

    if (confirm("Are you sure you want to clear the fields?")){
      this.props.resetDialogData();
      this.props.resetIsUpdateState();
    }
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

  createOrUpdateDialog(e){
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

    this.props.createOrUpdateDialog(data);
  },

  render() {
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
        <a href='#' onClick={this.resetForm} className='btn md grey pull-right'>Reset fields</a>
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

          <Message message={this.props.response} name='aneeda-says-error'>
          </Message>
          <hr className='margin0'></hr>

          <table className='dialog'>
            <tbody>
              {this.state['unresolved-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={input.id}
                    fields={this.props.fields}
                    name='unresolved-field'
                    title='is unresolved'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'unresolved-field')}
                    value={this.state['unresolved-field'][index].value}
                  ></DialogSelectbox>
                );
              }.bind(this))}
              {this.state['missing-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={input.id}
                    fields={this.props.fields}
                    name='missing-field'
                    title='is missing'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'missing-field')}
                    value={this.state['missing-field'][index].value}
                  ></DialogSelectbox>
                );
              }.bind(this))}
              {this.state['present-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={input.id}
                    fields={this.props.fields}
                    name='present-field'
                    title='is present'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'present-field')}
                    hasInput={true}
                    inputName='present-value'
                    inputPlaceholder='present value'
                    inputValue={this.state['present-field'][index].inputValue}
                    value={this.state['present-field'][index].value}
                  ></DialogSelectbox>
                );
              }.bind(this))}
              {this.state['awaiting-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={input.id}
                    fields={this.props.fields}
                    name='awaiting-field'
                    title='Awaiting field'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'awaiting-field')}
                    value={this.state['awaiting-field'][index].value}
                  ></DialogSelectbox>
                );
              }.bind(this))}
            </tbody>
          </table>

          <button
            onClick={this.createOrUpdateDialog}
            className='btn lg ghost dialog-btn pull-right'
          >{this.props.createOrUpdateBtnText()}</button> &nbsp;
        </form>
      </div>
    );
  }
});
