import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import {
  ProgressBar,
  Section,
  Tabs,
  Button,
  Stack,
  Input,
  BlockQuote,
  Collapsible,
  LabeledList,
  Modal,
} from '../components';
import { toFixed } from 'common/math';

export const BombProcessor = (props, context) => {
  return (
    <Window title="Bomb Processor" width={600} height={450}>
      <Window.Content>
        <BombProcessorContent />
      </Window.Content>
    </Window>
  );
};

export const BombProcessorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const ResultantGasmix = (
    <Section title={data.combined_gasmix.name}>
      {!(
        data.tank_gasmixes[0].total_moles && data.tank_gasmixes[1].total_moles
      ) && <Modal>{'No Gas Present'}</Modal>}
      <LabeledList>
        {data.combined_gasmix.gases.map((individual_gas) => (
          <LabeledList.Item label={individual_gas.gas_name}>
            {individual_gas.gas_mole +
              ' mol (' +
              (
                (individual_gas.gas_mole / data.combined_gasmix.total_moles) *
                100
              ).toFixed(2) +
              ' %)'}
          </LabeledList.Item>
        ))}
        <LabeledList.Item label="Temperature">
          {data.combined_gasmix.temperature + ' K'}
        </LabeledList.Item>
        <LabeledList.Item label="Volume">
          {data.combined_gasmix.volume + ' L'}
        </LabeledList.Item>
        <LabeledList.Item label="Pressure">
          {data.combined_gasmix.pressure + ' kPa'}
        </LabeledList.Item>
      </LabeledList>
      {data.reaction_increment !== 0 && (
        <Button
          title={
            'Valve Status: Open. Current Reaction Increment: ' +
            (data.reaction_increment - 1)
          }
          onClick={() => act('react')}>
          {'React'}
        </Button>
      )}
      {data.reaction_increment === 0 && (
        <Button title={'Valve Status: Closed.'} onClick={() => act('react')}>
          {'Open Valve'}
        </Button>
      )}
    </Section>
  );
  const TankComposition = tab === 1 && (
    <Section>
      <Stack>
        {data.tank_gasmixes.map((gasmix) => (
          <Stack.Item>
            <Section title={gasmix.name}>
              {!gasmix.total_moles && <Modal>{'No Gas Present'}</Modal>}
              <LabeledList>
                {gasmix.gases.map((individual_gas) => (
                  <LabeledList.Item label={individual_gas.gas_name}>
                    {individual_gas.gas_mole +
                      ' mol (' +
                      (
                        (individual_gas.gas_mole / gasmix.total_moles) *
                        100
                      ).toFixed(2) +
                      ' %)'}
                  </LabeledList.Item>
                ))}
                <LabeledList.Item label="Temperature">
                  {gasmix.temperature + ' K'}
                </LabeledList.Item>
                <LabeledList.Item label="Volume">
                  {gasmix.volume + ' L'}
                </LabeledList.Item>
                <LabeledList.Item label="Pressure">
                  {gasmix.pressure + ' kPa'}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
  const EligibleExperiments = tab === 2 && (
    <Section>
      {data.experiment_information.map((experiment) => (
        <Section title={experiment.name}>
          {experiment.description}
          <LabeledList>
            {Object.keys(experiment.midpoints).map((tier_index) => (
              <LabeledList.Item
                label={
                  'Target Amount - Tier ' + String(Number(tier_index) + 1)
                }>
                {experiment.midpoints[tier_index]}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      ))}
    </Section>
  );
  return (
    <Section>
      <Tabs>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          {'Tank Composition'}
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
          {'View Eligible Experiments'}
        </Tabs.Tab>
      </Tabs>
      {ResultantGasmix}
	  <Button disabled={!data.valve} onClick={() => act('eject')}>
        {'Eject Valve'}
      </Button>
      {TankComposition}
      {EligibleExperiments}
    </Section>
  );
};
