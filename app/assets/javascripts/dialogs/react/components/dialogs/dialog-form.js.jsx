var DialogForm = React.createClass({
  id: 'dialog-form',

  getInitialState() {
    return this.initialData();
  },

  initialData(){
    return {
      'unresolved-field':     [{id: 0, value: '', inputValue: ''}],
      'missing-field':        [{id: 0, value: '', inputValue: ''}],
      'present-field':        [{id: 0, value: 'None', inputValue: ''}],
      'awaiting-field':       [{id: 0, value: '', inputValue: ''}],
      'responses_attributes': [{id: 0, value: 'text', inputValue: '',
                                response_trigger: '', response_id: ''}],
      'entity-value-field':   [{id: 0, value: 'None', inputValue: ''}],
      priority: '',
      comments: ''
    };
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

  createNewIdFor(key, nextProps) {
    if (nextProps.data[key]){
      var ary  = [];
      var ary2 = [];
      var res  = [];

      nextProps.data[key].forEach(function(value, index){
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

  createNewIdForResponses(nextProps) {
    const ary = [];
    if (nextProps.data.responses) {
      nextProps.data.responses.forEach(function(response, index){
        const hsh = {};
        hsh['id'] = index;
        hsh['response_id'] = response.id.$oid;
        hsh['value'] = response.response_type;
        hsh['response_trigger'] = JSON.parse(response.response_trigger);
        hsh['inputValue'] = JSON.parse(response.response_value);

        ary.push(hsh);
      });

      return ary;
    }
  },

  componentWillReceiveProps(nextProps) {
    if(Object.keys(nextProps.data).length > 0) {
      this.setState({
        'unresolved-field':     this.createNewId('unresolved', nextProps),
        'missing-field':        this.createNewId('missing', nextProps),
        // 'present-field':        this.createNewIdForPresent(nextProps),
        'present-field':        this.createNewIdFor('present', nextProps),
        'entity-value-field':   this.createNewIdFor('entity_values',nextProps),
        'awaiting-field':       this.createNewId('awaiting_field', nextProps),
        'responses_attributes': this.createNewIdForResponses( nextProps ),
        priority:               nextProps.data.priority,
        response:               nextProps.data.response,
        comments:               nextProps.data.comments
      });
    } else {
      this.setState(this.initialData());
      this.props.resetIsUpdateState();
    }
  },

  priorityHandleChange(event) {
    this.setState({ priority: event.target.value });
  },

  commentsHandleChange(event) {
    this.setState({ comments: event.target.value });
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
      inputValue: '',
      response_trigger: '',
      response_id: ''
    });

    this.setState(currentState);
  },

  updateState(name, obj){
    if (this.state.responses_attributes[obj.id].value != obj.value) { // Response Type Changed
      this.state[name][obj.id] = obj;
    } else if ( obj.inputValue && Object.keys(obj.inputValue).length === 0 ) {
      // Update response_trigger only
      this.state[name][obj.id].response_trigger = obj.response_trigger;
    } else {
      this.state[name][obj.id] = obj;
    }

    this.setState({});
  },

  deleteInput(input, key){
    var newState = this.state[key];
    newState.splice(newState.indexOf(input), 1)

    this.setState(this.state);
  },

  deleteResponse(input){
    var new_state = this.state.responses_attributes;
    new_state.splice( new_state.indexOf(input), 1);

    this.setState(this.state);

    if (input['response_id']){
      $.ajax({
        type: 'DELETE',
        url: '/dialogue_api/response/' + input['response_id'],
      })
      .done(function(){
        console.log("-- Delete Response --");
      });
    }
  },

  resetForm(e){
    e.preventDefault();

    if (confirm("Are you sure you want to clear the fields?")){
      this.props.resetDialogData();
      this.props.resetIsUpdateState();
    }
  },

  createOrUpdateDialog(e){
    e.preventDefault();

    $('.dialogForm').hide();
    $('.dialogTable').show();
    $('.exportCSV').show();

    var data = {};

    data[ 'intent_id'      ] = this.props.intent_id;
    data[ 'priority'       ] = this.state.priority;

    data[ 'unresolved'     ] = this.state['unresolved-field'].map( (e)=>e.value );
    data[ 'missing'        ] = this.state['missing-field'].map( (e)=>e.value );
    data[ 'present'        ] = [].concat.apply( [], this.state['present-field'].map((e)=>[e.value, e.inputValue]) ); //concat.apply = merging
    data[ 'entity_values'   ] = [].concat.apply( [], this.state['entity-value-field'].map((e)=>[e.value, e.inputValue]) );
    data[ 'awaiting_field' ] = this.state['awaiting-field'].map( (e)=>e.value );
    data[ 'comments'       ] = this.state.comments;

    data[ 'responses_attributes' ] = this.state.responses_attributes.map( (e) => {
      if ( e.response_id ){
        return ({ id: e.response_id,
                  response_type: e.value,
                  response_trigger: JSON.stringify(e.response_trigger),
                  response_value: JSON.stringify(e.inputValue) });
      } else {
        return ({ response_type: e.value,
                  response_trigger: JSON.stringify(e.response_trigger),
                  response_value: JSON.stringify(e.inputValue) });
      }
    });

    this.props.createOrUpdateDialog(data);
  },

  cancelCreate(e){
    e.preventDefault();

    $('.dialogForm').hide();
    $('.dialogTable').show();
    $('.exportCSV').show();

    this.props.resetDialogData();
    this.props.resetIsUpdateState();
  },

  render() {
    return (
      <div className='dialogForm'>
        <h4 className='inline'>Responses</h4>
        <a href={this.props.field_path} className='addField btn md grey pull-right'>Manage fields</a>
        <a href='#' onClick={this.resetForm} className='btn md grey pull-right'>Reset</a>
        <div className='dialog-form'>
          <input type='hidden' name='intent-id' value={this.props.intent_id} />
          <hr className='margin50220'></hr>

          <div>
            <strong className='two columns margin0'>Priority</strong>
            <input
              className='three columns priority-input'
              name='priority'
              type='number'
              value={this.state.priority}
              onChange={this.priorityHandleChange} />
          </div>
          <br /><br />
          <Message message={this.props.response} name='aneeda-says-error'>
          </Message>
          <hr className='margin0'></hr>

          <table className='dialog'>
            <tbody>
              {/* ******************************************************** */}
              {this.state['responses_attributes'].map(function(input, index){
                return(
                  <ResponseType
                    key={input.id}
                    index={index}
                    name='responses_attributes'
                    className='response-type-text-with-option'
                    title='Response type'
                    addRow={this.addRow}
                    // deleteInput={this.deleteInput.bind(this, input, 'responses_attributes')}
                    deleteInput={this.deleteResponse.bind(this, input)}
                    value={this.state['responses_attributes'][index].value}
                    inputValue={this.state['responses_attributes'][index].inputValue}
                    response_trigger={this.state['responses_attributes'][index].response_trigger}
                    response_id={this.state['responses_attributes'][index].response_id}
                    updateState={this.updateState}
                  ></ResponseType>
                );
              }.bind(this))}
              {/* ******************************************************** */}

              {this.state['unresolved-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
                    fields={this.props.fields}
                    name='unresolved-field'
                    title='is unresolved'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'unresolved-field')}
                    value={this.state['unresolved-field'][index].value}
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}
              {this.state['missing-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
                    fields={this.props.fields}
                    name='missing-field'
                    title='is missing'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'missing-field')}
                    value={this.state['missing-field'][index].value}
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}
              {this.state['present-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
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
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}

              {this.state['entity-value-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
                    fields={this.props.fields}
                    name='entity-value-field'
                    title='entity value'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'entity-value-field')}
                    hasInput={true}
                    inputName='entity-value'
                    inputPlaceholder='entity value'
                    inputValue={this.state['entity-value-field'][index].inputValue}
                    value={this.state['entity-value-field'][index].value}
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}

              {this.state['awaiting-field'].map(function(input, index){
                return(
                  <DialogSelectbox
                    key={input.id}
                    index={index}
                    fields={this.props.fields}
                    name='awaiting-field'
                    title='Awaiting field'
                    addRow={this.addRow}
                    deleteInput={this.deleteInput.bind(this, input, 'awaiting-field')}
                    value={this.state['awaiting-field'][index].value}
                    updateState={this.updateState}
                  ></DialogSelectbox>
                );
              }.bind(this))}
            </tbody>
          </table>

          <div  className="bottom-pad128">
            <span>
              <strong className='two columns margin0 comments-label'>Comments</strong>
            </span>
            <textarea
              className='three columns comments-input'
              name='comments'
              value={this.state.comments}
              onChange={this.commentsHandleChange}
            />
          </div>

          <button
            onClick={this.createOrUpdateDialog}
            className='btn lg ghost dialog-btn pull-right'
          >{this.props.createOrUpdateBtnText()}</button> &nbsp;
          <a
            href='#'
            className='cancelCreate pull-right'
            onClick={(e) => this.cancelCreate(e)}
          >
            Cancel
          </a>
        </div>
      </div>
    );
  }
});
