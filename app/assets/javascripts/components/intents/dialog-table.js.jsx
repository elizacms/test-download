var DialogTable = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  render() {
    return (
      <div>
        <hr className='margin0'></hr>
        <table className='dialogs'>
          <tbody>
            <tr>
              <th className='row10'>&nbsp;Priority</th>
              <th className='row30'>AneedA Says</th>
              <th className='row30'>Rules</th>
              <th className='row10'>Awaiting Field</th>
              <th className='row5'></th>
            </tr>
            {
              this.props.data.map(function(dialog, index){
                return <DialogRow deleteRow={this.props.deleteRow} data={dialog} key={ index }>{dialog}</DialogRow>;
              }.bind(this))
            }
          </tbody>
        </table>
      </div>
    );
  }
});
