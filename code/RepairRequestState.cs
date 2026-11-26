// State үлгісі: өтінім күйінің ауысуын бөлек кластарға береді.
namespace ComputerRepair;

public interface IRepairState
{
    string Name { get; }
    IRepairState Advance();
}

public sealed class RepairRequestStateMachine
{
    private IRepairState _state = new NewState();

    public string CurrentStatus => _state.Name;

    public void Advance()
    {
        _state = _state.Advance();
    }
}

public sealed class NewState : IRepairState
{
    public string Name => "Жаңа";
    public IRepairState Advance() => new DiagnosisState();
}

public sealed class DiagnosisState : IRepairState
{
    public string Name => "Диагностика";
    public IRepairState Advance() => new RepairingState();
}

public sealed class RepairingState : IRepairState
{
    public string Name => "Жөндеуде";
    public IRepairState Advance() => new ReadyState();
}

public sealed class ReadyState : IRepairState
{
    public string Name => "Дайын";
    public IRepairState Advance() => new CompletedState();
}

public sealed class CompletedState : IRepairState
{
    public string Name => "Аяқталды";
    public IRepairState Advance() => this;
}

